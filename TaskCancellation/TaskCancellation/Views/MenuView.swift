//
//  MenuView.swift
//  TaskCancellation
//
//  Created by Peter Friese on 07.07.21.
//

import SwiftUI

struct MenuView: View {
  @State
  var isBookSearchNoCancellationPresented = false
  var body: some View {
    List {
      Section("No task cancellation") {
        NavigationButton(Label("Search books (on submit)", systemImage: "1.square")) {
          BookSearchNoCancellationView()
        }
        NavigationButton(Label("Search books (live)", systemImage: "2.square")) {
          BookSearchNoCancellationLiveView()
        }
      }
      Section("Task cancellation") {
        NavigationButton(Label("Search books (live)", systemImage: "3.square")) {
          BookSearchTaskCancellationView()
        }
        NavigationButton(Label("Search books (actor, live)", systemImage: "4.square")) {
          BookSearchActorTaskCancellationView()
        }
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
