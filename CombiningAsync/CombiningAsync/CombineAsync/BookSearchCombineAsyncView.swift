//
//  BookSearchCombineAsyncView.swift
//  CombiningAsync
//
//  Created by Peter Friese on 18.03.22.
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
      .dropFirst()
      .debounce(for: 0.8, scheduler: DispatchQueue.main)
      .removeDuplicates()
      .handleEvents {
        self.isSearching = true
      }
    // this is equivalent to the following call:
//      .handleEvents(receiveOutput: { output in
//        self.isSearching = true
//      })
      .await { searchTerm in
        await self.searchBooks(matching: searchTerm)
      }
    //  this is equivalent to this solution [VIDEO: use the same callouts as Codeslicing!]
//      .flatMap { value in
//        Future { promise in
//          Task {
//            let result = await self.searchBooks(matching: value)
//            promise(.success(result))
//          }
//        }
//      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
      .handleEvents {
        self.isSearching = false
      }
      .assign(to: &$result)
  }
  
  private func searchBooks(matching searchTerm: String) async -> [Book] {
    let escapedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    let url = URL(string: "https://openlibrary.org/search.json?q=\(escapedSearchTerm)")!
    
    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      
      let searchResult = try OpenLibrarySearchResult.init(data: data)
      guard let libraryBooks = searchResult.books else { return [] }
      return libraryBooks.compactMap { Book(from: $0) }
    }
    catch {
      return []
    }
  }
}

struct BookSearchCombineAsyncView: View {
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

struct BookCombineAsyncView_Previews: PreviewProvider {
  static var previews: some View {
    BookSearchCombineAsyncView()
  }
}
