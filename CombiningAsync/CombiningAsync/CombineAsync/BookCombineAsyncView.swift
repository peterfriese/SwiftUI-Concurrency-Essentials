//
//  BookCombineAsyncView.swift
//  CombiningAsync
//
//  Created by Peter Friese on 18.03.22.
//

import SwiftUI

fileprivate class ViewModel: ObservableObject {
  @Published var searchTerm: String = ""
  
  @Published private(set) var result: [Book] = []
  @Published private(set) var isSearching = false
  
  private var searchTask: Task<Void, Never>?
  
  @MainActor
  func executeQuery() async {
    searchTask?.cancel()
    let currentSearchTerm = searchTerm.trimmingCharacters(in: .whitespaces)
    if currentSearchTerm.isEmpty {
      result = []
      isSearching = false
    }
    else {
      searchTask = Task {
        isSearching = true
        result = await searchBooks(matching: searchTerm)
        if !Task.isCancelled {
          isSearching = false
        }
      }
    }
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
    .navigationTitle("Search (async)")
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button(action: { dismiss() }) {
          Text("Done")
        }
      }
    }
    .searchable(text: $viewModel.searchTerm)
    // uncomment the following line to kick off the search 0.8 seconds after the user stopped typing
    //    .onReceive(viewModel.$searchTerm.debounce(for: 0.8, scheduler: RunLoop.main)) { searchTerm in
    .onReceive(viewModel.$searchTerm) { searchTerm in
      Task {
        await viewModel.executeQuery()
      }
    }
  }
}

struct BookCombineAsyncView_Previews: PreviewProvider {
  static var previews: some View {
    BookSearchCombineAsyncView()
  }
}
