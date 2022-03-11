//
//  BookSearchNoCancellationView.swift
//  TaskCancellation
//
//  Created by Peter Friese on 07.07.21.
//

import SwiftUI

// @MainActor
//
// Change for Swift 5.6 / Xcode 13.3:
// Using @MainActor here will result in a warning when initialising the ObservableObject like this:
//   @StateObject var viewModel = WordDetailsViewModel()
//
// This will result in the following warning:
// Expression requiring global actor 'MainActor' cannot appear in default-value expression of
// property '_viewModel'; this is an error in Swift 6
//
// To resolve this issue, we only mark the functions that actually make changes to published properties
// using @MainActor.
fileprivate class ViewModel: ObservableObject {
  @Published var searchTerm: String = ""
  
  @Published private(set) var result: [Book] = []
  @Published private(set) var isSearching = false
  
  @MainActor
  func executeQuery() async {
    let currentSearchTerm = searchTerm.trimmingCharacters(in: .whitespaces)
    if currentSearchTerm.isEmpty {
      result = []
      isSearching = false
    }
    else {
      Task {
        isSearching = true
        result = await searchBooks(matching: searchTerm)
        isSearching = false
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

struct BookSearchNoCancellationView: View {
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
    .navigationTitle("Search (on submit)")
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button(action: { dismiss() }) {
          Text("Done")
        }
      }
    }
    .searchable(text: $viewModel.searchTerm)
    .onSubmit(of: .search) {
      Task {
        await viewModel.executeQuery()
      }
    }
  }
}

struct BookSearchNoCancellationView_Previews: PreviewProvider {
  static var previews: some View {
    BookSearchNoCancellationView()
  }
}
