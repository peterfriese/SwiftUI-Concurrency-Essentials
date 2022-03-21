//
//  CombiningAsyncApp.swift
//  CombiningAsync
//
//  Created by Peter Friese on 14.03.22.
//

import SwiftUI

@main
struct CombiningAsyncApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationView {
        MenuView()
          .navigationTitle("Combining Async")
      }
    }
  }
}
