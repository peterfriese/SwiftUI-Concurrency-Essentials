//
//  ContentView.swift
//  WordBrowser
//
//  Created by Peter Friese on 16.06.21.
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
class WordsAPIViewModel: ObservableObject {
  @Published var searchTerm: String = ""
  @Published var isSearching = false
  @Published var result = Word.sample
  @Published var definitions = [Definition]()
  
  init() {
    $result
      .compactMap { $0.definitions }
      .assign(to: &$definitions)
  }

  @MainActor
  func executeQuery() async {
    Task {
      isSearching.toggle()
      result = await search(for: searchTerm)
      isSearching.toggle()
    }
  }
  
  private func buildURLRequest(for term: String) -> URLRequest {
    let escapedSearchTerm = term.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    let url = URL(string: "https://wordsapiv1.p.rapidapi.com/words/\(escapedSearchTerm)/definitions")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue(WordsAPISecrets.apiKey, forHTTPHeaderField: WordsAPISecrets.apiKeyHeader)
    request.setValue(WordsAPISecrets.apiHost, forHTTPHeaderField: WordsAPISecrets.apiHostHeader)
    return request
  }
  
  private func search(for term: String) async -> Word {
    // build the request
    let request = buildURLRequest(for: term)

    do {
      let (data, response) = try await URLSession.shared.data(for: request)
      guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw WordsAPIError.invalidServerResponse
      }
      return try Word(data: data)
    }
    catch {
      return Word.empty
    }
  }
}

struct WordSearchView: View {
  @StateObject var viewModel = WordsAPIViewModel()
  var body: some View {
    List {
      Text(viewModel.result.word)
        .bold()
      Section("Definitions") {
        ForEach(viewModel.definitions) { definition in
          DefinitionView(definition: definition)
        }
      }
    }
    .searchable(text: $viewModel.searchTerm)
    .autocapitalization(.none)
    .overlay {
      if viewModel.isSearching {
        ProgressView()
      }
    }
    .onSubmit(of: .search) {
      Task {
        await viewModel.executeQuery()
      }
    }
    .task {
      viewModel.searchTerm = "Swift"
      await viewModel.executeQuery()
    }
    .navigationTitle("Definitions")
  }
}

struct WordSearchView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      WordSearchView()
    }
  }
}
