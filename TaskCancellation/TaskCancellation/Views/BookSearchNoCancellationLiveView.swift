//
//  BookSearchNoCancellationLiveView.swift
//  TaskCancellation
//
//  Created by Peter Friese on 07.07.21.
//

import SwiftUI

@MainActor
fileprivate class ViewModel: ObservableObject {
  @Published var searchTerm: String = ""
  
  @Published private(set) var result: [Book] = []
  @Published private(set) var isSearching = false
  
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

struct BookSearchNoCancellationLiveView: View {
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
    .navigationTitle("Search (live)")
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

struct BookSearchNoCancellationLiveView_Previews: PreviewProvider {
  static var previews: some View {
    BookSearchNoCancellationLiveView()
  }
}
