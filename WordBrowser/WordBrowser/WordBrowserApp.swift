//
//  WordBrowserApp.swift
//  WordBrowser
//
//  Created by Peter Friese on 16.06.21.
//

import SwiftUI

@main
struct WordBrowserApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationView {
        LibraryView()
      }
    }
  }
}
