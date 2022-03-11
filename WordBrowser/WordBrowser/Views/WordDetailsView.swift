//
//  WordDetailsView.swift
//  WordBrowser
//
//  Created by Peter Friese on 18.06.21.
//

import SwiftUI

enum WordsAPIError: Error {
  case invalidServerResponse
}

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
class WordDetailsViewModel: ObservableObject {
  // output
  @Published private var result = Word.empty
  @Published var isSearching = false
  @Published var definitions = [Definition]()
  
  init() {
    $result
      .compactMap { $0.definitions }
      .assign(to: &$definitions)
  }
  
  func refresh() async {
  }
  
  @MainActor
  func executeQuery(for searchTerm: String) async {
    isSearching = true
    // pause 1 second to make the effect more obvious
    await Task.sleep(1_000_000_000)
    result = await search(for: searchTerm)
    isSearching = false
  }
  
  private func buildURLRequest(for searchTerm: String) -> URLRequest {
    let escapedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    let url = URL(string: "https://wordsapiv1.p.rapidapi.com/words/\(escapedSearchTerm)/definitions")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue(WordsAPISecrets.apiKey, forHTTPHeaderField: WordsAPISecrets.apiKeyHeader)
    request.setValue(WordsAPISecrets.apiHost, forHTTPHeaderField: WordsAPISecrets.apiHostHeader)
    return request
  }
  
  private func search(for searchTerm: String) async -> Word {
    // build the request
    let request = buildURLRequest(for: searchTerm)
    
    do {
      let (data, response) = try await URLSession.shared.data(for: request)
      guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw WordsAPIError.invalidServerResponse
      }
      let word = try JSONDecoder().decode(Word.self, from: data)
      return word
    }
    catch {
      return Word.empty
    }
  }
}


struct WordDetailsView: View {
  @State var word: String
  @State var definitions = [Definition]()
  @StateObject var viewModel = WordDetailsViewModel()
  
  var body: some View {
    ZStack {
      if viewModel.isSearching {
        ProgressView("Fetching...")
      }
      else {
        List {
          Section("Definitions") {
            ForEach(viewModel.definitions) { definition in
              DefinitionView(definition: definition)
            }
          }
          .lineLimit(2)
        }
      }
    }
    .navigationTitle(word)
    .task {
      await viewModel.executeQuery(for: word)
    }
  }
}

struct WordDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      WordDetailsView(word: "Swift")
    }
  }
}
