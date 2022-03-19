//
//  Book.swift
//  CombiningAsync
//
//  Created by Peter Friese on 14.03.22.
//

import Foundation

struct Book: Codable,  Identifiable {
  var id: String
  var title: String
  var author: String
  var isbn: String
  var pages: Int
  var isRead: Bool = false
  var coverEditionKey: String?
}

extension Book {
  var hasImageUrl: Bool {
    coverEditionKey != nil
  }
  
  var smallCoverImageUrl: URL? { return URL(string: "https://covers.openlibrary.org/b/olid/\(coverEditionKey ?? "")-S.jpg") }
  var mediumCoverImageUrl: URL? { return URL(string: "https://covers.openlibrary.org/b/olid/\(coverEditionKey ?? "")-M.jpg") }
  var largeCoverImageUrl: URL? { return URL(string: "https://covers.openlibrary.org/b/olid/\(coverEditionKey ?? "")-L.jpg") }
  
  var smallCoverImageName: String { return "\(isbn)-S" }
  var mediumCoverImageName: String { return "\(isbn)-M" }
  var largeCoverImageName: String { return "\(isbn)-L" }
}

extension Book {
  static let reading = [
    Book(id: "1", title: "Why we sleep", author: "Matthew Walker", isbn: "9780141983769", pages: 368),
    Book(id: "2", title: "The Hitchhiker's Guide to the Galaxy", author: "Douglas Adams", isbn: "9780671461492", pages: 216),
  ]
  
  static let wantToRead = [
    Book(id: "3", title: "Changer", author: "Matt Gemmell", isbn: "9781916265202", pages: 476),
  ]
  
  static let read = [
    Book(id: "4", title: "Desing Patterns", author: "Erich Gamma", isbn: "0201633612", pages: 395, isRead: true, coverEditionKey: "OL22173620M"),
    Book(id: "5", title: "SwiftUI for Absolute Beginners", author: "Jayant Varma", isbn: "9781484255155", pages: 200)
  ]
  
  static let samples = [reading, wantToRead, read].flatMap { $0 }
}
