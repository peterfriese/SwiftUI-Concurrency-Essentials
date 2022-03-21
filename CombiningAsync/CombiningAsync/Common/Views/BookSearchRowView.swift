//
//  BookSearchRowView.swift
//  CombiningAsync
//
//  Created by Peter Friese on 14.03.22.
//

import SwiftUI

struct BookSearchRowView: View {
  var book: Book
  var body: some View {
    VStack(alignment: .leading) {
      Text(book.title)
        .font(.headline)
      Text("by \(book.author)")
        .font(.subheadline)
    }
  }
}

struct BookSearchRowView_Previews: PreviewProvider {
  static var previews: some View {
    BookSearchRowView(book: Book.samples[0])
  }
}
