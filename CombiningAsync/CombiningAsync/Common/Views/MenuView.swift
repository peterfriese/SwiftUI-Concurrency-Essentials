//
//  MenuView.swift
//  CombiningAsync
//
//  Created by Peter Friese on 14.03.22.
//

import SwiftUI

struct MenuView: View {
  var body: some View {
    List {
      NavigationButton(Label("Search books w/ Combine", systemImage: "1.square")) {
        BookSearchCombineView()
      }
      NavigationButton(Label("Search books w/ async/wait", systemImage: "2.square")) {
        BookSearchAsyncView()
      }
      NavigationButton(Label("Search books w/ Combine & async/await", systemImage: "5.square")) {
        BookSearchCombineAsyncView()
      }
    }
  }
}

struct MenuView_Previews: PreviewProvider {
  static var previews: some View {
    MenuView()
  }
}

struct NavigationButton<Label, Destination>: View where Label: View, Destination: View {
  @State
  private var isSheetPresented = false
  
  private var title: Label
  private var description: String?
  private var destination: () -> Destination
  
  public init(_ title: Label, description: String? = nil, @ViewBuilder destination: @escaping () -> Destination) {
    self.title = title
    self.description = description
    self.destination = destination
  }
  
  var body: some View {
    Button(action: { isSheetPresented.toggle()} ) {
      title
        .sheet(isPresented: $isSheetPresented) {
          NavigationView {
            destination()
          }
        }
    }
  }
}
