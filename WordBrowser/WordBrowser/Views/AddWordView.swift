//
//  AddWordView.swift
//  WordBrowser
//
//  Created by Peter Friese on 21.06.21.
//

import SwiftUI

struct AddWordView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var word: String = ""
  
  var onAddWord: (String) -> Void
  
  var body: some View {
    Form {
      TextField("Word", text: $word)
        .autocapitalization(.none)
        .disableAutocorrection(true)
    }
    .navigationTitle("Add New")
    .onSubmit(handleOnAddWord)
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") {
          dismiss()
        }
      }
      ToolbarItem(placement: .confirmationAction) {
        Button("Done", action: handleOnAddWord)
          .disabled(word.isEmpty)
      }
    }
  }
  
  private func handleOnAddWord() {
    onAddWord(word)
    dismiss()
  }
}

struct AddWordView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      AddWordView { word in
        print(word)
      }
    }
  }
}
