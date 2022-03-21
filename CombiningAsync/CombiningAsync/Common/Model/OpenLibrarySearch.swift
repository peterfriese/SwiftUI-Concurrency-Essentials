//
//  OpenLibrarySearch.swift
//  CombiningAsync
//
//  Created by Peter Friese on 14.03.22.
//

import Foundation

// Data model for searching Open Library (https://openlibrary.org/dev/docs/api/books)
// Generated using https://app.quicktype.io/ from the JSON that is produced
// by this query: http://openlibrary.org/search.json?q=%22why%20we%20sleep%22

// MARK: - OpenLibrarySearchResult
struct OpenLibrarySearchResult: Codable {
  let numFound, start: Int?
  let books: [OpenLibrarySearchResultBook]?
  let openLibrarySearchResultNumFound: Int?
  
  enum CodingKeys: String, CodingKey {
    case numFound, start
    case books = "docs"
    case openLibrarySearchResultNumFound = "num_found"
  }
  
  init(data: Data) throws {
    self = try JSONDecoder().decode(OpenLibrarySearchResult.self, from: data)
  }
}

// MARK: - OpenLibrarySearchResultBook
struct OpenLibrarySearchResultBook: Codable {
  let coverI: Int?
  let hasFulltext: Bool?
  let title, titleSuggest, type: String?
  let ebookCountI, editionCount: Int?
  let key: String?
  let lastModifiedI: Int?
  let coverEditionKey: String?
  let firstPublishYear: Int?
  let authorName: [String]?
  let publishYear: [Int]?
  let ddc, authorKey, idAmazon, seed: [String]?
  let subject, authorAlternativeName, isbn, editionKey: [String]?
  let language, lcc, idGoodreads, lccn: [String]?
  let person, oclc, publisher, text: [String]?
  let publishDate: [String]?
  let lendingIdentifierS, iaCollectionS, printdisabledS: String?
  let publicScanB: Bool?
  let lendingEditionS: String?
  let idLibrarything, publishPlace, iaBoxID, ia: [String]?
  
  enum CodingKeys: String, CodingKey {
    case coverI = "cover_i"
    case hasFulltext = "has_fulltext"
    case title
    case titleSuggest = "title_suggest"
    case type
    case ebookCountI = "ebook_count_i"
    case editionCount = "edition_count"
    case key
    case lastModifiedI = "last_modified_i"
    case coverEditionKey = "cover_edition_key"
    case firstPublishYear = "first_publish_year"
    case authorName = "author_name"
    case publishYear = "publish_year"
    case ddc
    case authorKey = "author_key"
    case idAmazon = "id_amazon"
    case seed, subject
    case authorAlternativeName = "author_alternative_name"
    case isbn
    case editionKey = "edition_key"
    case language, lcc
    case idGoodreads = "id_goodreads"
    case lccn, person, oclc, publisher, text
    case publishDate = "publish_date"
    case lendingIdentifierS = "lending_identifier_s"
    case iaCollectionS = "ia_collection_s"
    case printdisabledS = "printdisabled_s"
    case publicScanB = "public_scan_b"
    case lendingEditionS = "lending_edition_s"
    case idLibrarything = "id_librarything"
    case publishPlace = "publish_place"
    case iaBoxID = "ia_box_id"
    case ia
  }
  
  init(data: Data) throws {
    self = try JSONDecoder().decode(OpenLibrarySearchResultBook.self, from: data)
  }
}


extension Book {
  init(from openLibraryBook: OpenLibrarySearchResultBook) {
    let title = openLibraryBook.title ?? ""
    let authorName = (openLibraryBook.authorName != nil) ? openLibraryBook.authorName?[0] : ""
    let isbn = (openLibraryBook.isbn != nil) ? openLibraryBook.isbn?[0] : ""
    let key = openLibraryBook.key ?? UUID().uuidString
    
    self.id = key
    self.title = title
    self.author = authorName ?? ""
    self.isbn = isbn ?? ""
    self.pages = 0
    self.coverEditionKey = openLibraryBook.coverEditionKey ?? ""
  }
}

