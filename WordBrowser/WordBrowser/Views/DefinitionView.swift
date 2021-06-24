//
//  DefinitionView.swift
//  WordBrowser
//
//  Created by Peter Friese on 16.06.21.
//

import SwiftUI

struct DefinitionView: View {
  var definition: Definition
  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text("(\(definition.partOfSpeech))")
          .font(.caption)
        Text(definition.definition)
      }
      Spacer()
    }
  }
}

struct DefinitionView_Previews: PreviewProvider {
  static var previews: some View {
    DefinitionView(definition: Word.sample.definitions![0])
      .previewLayout(.sizeThatFits)
  }
}
