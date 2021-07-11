//
//  BookSearchRowView.swift
//  TaskCancellation
//
//  Created by Peter Friese on 07.07.21.
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
