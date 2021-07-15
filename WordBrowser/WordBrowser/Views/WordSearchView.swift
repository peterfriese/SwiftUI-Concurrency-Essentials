//
//  ContentView.swift
//  WordBrowser
//
//  Created by Peter Friese on 16.06.21.
//

import SwiftUI

@MainActor
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
      let (data, _) = try await URLSession.shared.data(for: request)
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
    WordSearchView()
  }
}
