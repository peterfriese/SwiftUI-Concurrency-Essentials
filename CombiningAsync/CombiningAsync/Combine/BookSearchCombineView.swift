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
      .handleEvents {
        self.isSearching = true
      }
//      .handleEvents({ value in
//        self.isSearching = true
//      })
//      .handleEvents(receiveOutput: { value in
//        self.isSearching = true
//      })
      .map { searchTerm -> AnyPublisher<[Book], Never> in
        self.isSearching = true
        return self.searchBooks(matching: searchTerm)
      }
      .switchToLatest()
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: { books in
        self.result = books
        self.isSearching = false
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
        openLibraryBooks?.map { Book(from: $0) }
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
