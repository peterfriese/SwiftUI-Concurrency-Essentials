//
//  BookSearchCombineView.swift
//  CombiningAsync
//
//  Created by Peter Friese on 14.03.22.
//

import SwiftUI
import Combine

fileprivate class ViewModel: ObservableObject {
  // MARK: - Input
  @Published var searchTerm: String = ""
  
  // MARK: - Output
  @Published private(set) var result: [Book] = []
  @Published var isSearching = false
  
  // MARK: - Private
  private var cancellables = Set<AnyCancellable>()
  
  init() {
    $searchTerm
      .debounce(for: 0.8, scheduler: DispatchQueue.main)
      .perform { self.isSearching = true }
      // this is equivalent to the following:
//      .map { value -> String in
//        self.isSearching = true
//        return value
//      }
      .flatMap { searchTerm -> AnyPublisher<[Book], Never> in
        
        // consider building a progress toggle passthrough operator. Check Mark's book to see what he suggests
//        self.isSearching = true
        print("FlatMap on thread: \(Thread.current) [\(Thread.isMainThread)]" )
        let result = self.searchBooks(matching: searchTerm)
        
        // NOTE: calling self.searchBooks will return immediately (as it returns a publisher)
        return result
      }
      .subscribe(on: DispatchQueue.global()) // since we use debounce, the pipeline will subscribe on the main thread, and this line has no effect!
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
      .perform { self.isSearching = false }
      .sink(receiveValue: { books in
        print("Receiving on thread: \(Thread.current) [\(Thread.isMainThread)]" )
        self.result = books
//        self.isSearching = false
      })
      .store(in: &cancellables)
  }
  
  private func searchBooks(matching searchTerm: String) -> AnyPublisher<[Book], Never> {
    let escapedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    let url = URL(string: "https://openlibrary.org/search.json?q=\(escapedSearchTerm)")!
    
    return URLSession.shared.dataTaskPublisher(for: url)
      .map(\.data)
      .decode(type: OpenLibrarySearchResult.self, decoder: JSONDecoder())
      .map(\.books)
      .compactMap { openLibraryBooks in
        openLibraryBooks?.map { openLibrarySearchResultBook in
          Book(from: openLibrarySearchResultBook)
        }
      }
      .replaceError(with: [Book]())
      .eraseToAnyPublisher()
  }
}

struct BookSearchCombineView: View {
  @Environment(\.dismiss) var dismiss
  
  @StateObject
  fileprivate var viewModel = ViewModel()
  
  var body: some View {
    List(viewModel.result) { book in
      BookSearchRowView(book: book)
    }
    .overlay {
      if viewModel.isSearching {
        ProgressView()
      }
    }
    .navigationTitle("Search (Combine)")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button(action: { dismiss() }) {
          Text("Done")
        }
      }
    }
    .searchable(text: $viewModel.searchTerm)
  }
}

struct BookSearchCombineView_Previews: PreviewProvider {
    static var previews: some View {
        BookSearchCombineView()
    }
}
