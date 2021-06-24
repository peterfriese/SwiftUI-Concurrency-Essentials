//
//  WordDetailsViewNoViewModel.swift
//  WordBrowser
//
//  Created by Peter Friese on 22.06.21.
//

import SwiftUI

struct WordDetailsViewNoViewModel: View {
  @State var word: String
  @State var isSearching = false
  @State var definitions = [Definition]()
  
  private func buildURLRequest(for term: String) -> URLRequest {
    let escapedSearchTerm = term.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    let url = URL(string: "https://wordsapiv1.p.rapidapi.com/words/\(escapedSearchTerm)/definitions")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue(WordsAPISecrets.apiKey, forHTTPHeaderField: WordsAPISecrets.apiKeyHeader)
    request.setValue(WordsAPISecrets.apiHost, forHTTPHeaderField: WordsAPISecrets.apiHostHeader)
    return request
  }
  
  func search(for term: String) async -> Word {
    // build the request
    let request = buildURLRequest(for: term)
    
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
  
  var body: some View {
    ZStack {
      if isSearching {
        ProgressView("Fetching...")
      }
      else {
        List {
          Section("Definitions") {
            ForEach(definitions) { definition in
              DefinitionView(definition: definition)
            }
          }
          .lineLimit(2)
        }
      }
    }
    .navigationTitle(word)
    .task {
      let result = await search(for: word)
      definitions = result.definitions ?? []
    }
  }
}

struct WordDetailsViewNoViewModel_Previews: PreviewProvider {
  static var previews: some View {
    WordDetailsViewNoViewModel(word: "Swift")
  }
}
