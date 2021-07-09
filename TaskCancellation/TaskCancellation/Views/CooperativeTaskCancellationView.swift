//
//  CooperativeTaskCancellationView.swift
//  TaskCancellation
//
//  Created by Peter Friese on 09.07.21.
//

import SwiftUI

fileprivate class ViewModel: ObservableObject {
  @Published var input: Int = 50
  @Published private(set) var output: Int?
  @Published private(set) var errorMessage: String?
  @Published private(set) var progress: Int = 0
  
  private var computeHandle: Task.Handle<Void, Error>?
  
  @MainActor
  func compute() {
    output = nil
    errorMessage = nil
    computeHandle = async {
      do {
        output = try await fiboncacci(nth: input) { progress in
          self.progress = ((progress + 1) * 100 / self.input)
        }
      }
      catch is Task.CancellationError {
        errorMessage = "You cancelled the computation"
      }
    }
  }
  
  func abort() {
    computeHandle?.cancel()
  }
  
  private func fiboncacci(nth: Int, progress: ((Int) -> Void)? = nil) async throws -> Int {
    var last = 0
    var current = 1
    
    for i in 0..<nth {
      // this is the real computation
      (current, last) = (current + last, current)
      
      // simulate compute-intensive behaviour
      await Task.sleep(75_000_000)
      
      // report progress
      progress?(i)
      
      // cooperative cancellation
      try Task.checkCancellation()
    }
    
    return last
  }
  
  // the recursive solution preforms really badly (O(n^2))
  private func fiboncacciRecursive(nth: Int, progress: ((Int) -> Void)? = nil) async  -> Int {
    await Task.yield()
    
    return nth <= 1
      ? nth
      : await fiboncacciRecursive(nth: nth - 1) + fiboncacciRecursive(nth: nth - 2)
  }
  
}



struct CooperativeTaskCancellationView: View {
  @StateObject
  private var viewModel = ViewModel()
  
  var body: some View {
    Form {
      Section("Input") {
        TextField("Value", value: $viewModel.input, format: .number, prompt: Text("Enter a value"))
        Button(action: { viewModel.compute() }) {
          Text("Compute the nth fibonacci numnber")
        }
        Button(role: .destructive, action: { viewModel.abort() }) {
          Text("Abort")
        }
      }
      Section("Output") {
        ProgressView(value: Float(viewModel.progress), total: 100) {
          HStack {
            Spacer()
            Text("\(viewModel.progress) %")
              .font(.subheadline)
          }
        }
        HStack {
          Text("Result:")
          if let result = viewModel.output {
            Text("\(result)")
          }
          else if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
              .foregroundColor(.red)
          }
          else {
            Text("result pending").redacted(reason: .placeholder)
          }
        }
      }
    }
    .navigationTitle("Task cancellation")
  }
}

struct CooperativeTaskCancellationView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      CooperativeTaskCancellationView()
    }
  }
}
