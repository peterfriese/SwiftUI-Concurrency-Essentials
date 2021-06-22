// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let word = try? newJSONDecoder().decode(Word.self, from: jsonData)

import Foundation

// MARK: - Word
struct Word {
  let word: String
  let definitions: [Definition]?
}

extension Word {
  static let empty = Word(word: "(no result)",
                          definitions: [
                            Definition(definition: "(no result))", partOfSpeech: "no result"),
                          ])
  
  static let sample = Word(word: "Swift",
                           definitions: [
                            Definition(definition: "moving very fast", partOfSpeech: "adjective"),
                            Definition(definition: "a small bird that resembles a swallow and is noted for its rapid flight", partOfSpeech: "noun"),
                           ])
}

extension Word: Codable {
  init(data: Data) throws {
    self = try JSONDecoder().decode(Word.self, from: data)
  }
}

// MARK: - Definition
struct Definition: Codable {
  let definition: String
  let partOfSpeech: String
}

extension Definition: Identifiable {
  var id: String { self.definition }
}

// MARK: - API Keys

struct WordsAPISecrets {
  
  static let apiKeyHeader = "x-rapidapi-key"
  static let apiHostHeader = "x-rapidapi-host"

  static var apiKey: String {
    get {
      // 1
      guard let filePath = Bundle.main.path(forResource: "WordsAPI-Info", ofType: "plist") else {
        fatalError("Couldn't find file 'WordsAPI-Info.plist'.")
      }
      // 2
      let plist = NSDictionary(contentsOfFile: filePath)
      guard let value = plist?.object(forKey: "API_KEY") as? String else {
        fatalError("Couldn't find key 'API_KEY' in 'WordsAPI-Info.plist'.")
      }
      // 3
      if (value.starts(with: "_")) {
        fatalError("Register for a WordsAPI developer account and get an API key at https://www.wordsapi.com/.")
      }
      return value
    }
  }
  
  static var apiHost: String {
    get {
      // 1
      guard let filePath = Bundle.main.path(forResource: "WordsAPI-Info", ofType: "plist") else {
        fatalError("Couldn't find file 'WordsAPI-Info.plist'.")
      }
      // 2
      let plist = NSDictionary(contentsOfFile: filePath)
      guard let value = plist?.object(forKey: "API_HOST") as? String else {
        fatalError("Couldn't find key 'API_HOST' in 'WordsAPI-Info.plist'.")
      }
      // 3
      if (value.starts(with: "_")) {
        fatalError("Register for a WordsAPI developer account and get an API key at https://www.wordsapi.com/.")
      }
      return value
    }
  }


}
