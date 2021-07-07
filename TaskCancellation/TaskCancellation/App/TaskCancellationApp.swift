//
//  TaskCancellationApp.swift
//  TaskCancellation
//
//  Created by Peter Friese on 07.07.21.
//

import SwiftUI

@main
struct TaskCancellationApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationView {
        MenuView()
          .navigationTitle("Task cancellation")
          .accentColor(Color(UIColor.systemPink))
      }
    }
  }
}
