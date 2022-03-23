//
//  Publisher+Async.swift
//  CombiningAsync
//
//  Created by Peter Friese on 16.03.22.
//

import Foundation
import Combine
import SwiftUI

extension Publisher {
  
  /// Executes an asyncronous call and returns its result to the downstream subscriber.
  ///
  /// - Parameter transform: A closure that takes an element as a parameter and returns a publisher that produces elements of that type.
  /// - Returns: A publisher that transforms elements from an upstream  publisher into a publisher of that element’s type.
  func `await`<T>(_ transform: @escaping (Output) async -> T) -> AnyPublisher<T, Failure> {
    flatMap { value -> Future<T, Failure> in
      Future { promise in
        Task {
          let result = await transform(value)
          promise(.success(result))
        }
      }
    }
    .eraseToAnyPublisher()
  }
  
  /// Performs the specified closures when publisher events occur.
  ///
  /// This is an overloaded version of ``Publisher/handleEvents(receiveSubscription:receiveOutput:receiveCompletion:receiveCancel:receiveRequest:)`` that only
  /// accepts a closure for the `receiveOutput` events. Use it to inspect events as they pass through the pipeline.
  ///
  /// - Parameters:
  ///   - receiveOutput: A closure that executes when the publisher receives a value from the upstream publisher.
  /// - Returns: A publisher that performs the specified closures when publisher events occur.
  func handleEvents(_ receiveOutput: (@escaping (Self.Output) -> Void)) -> Publishers.HandleEvents<Self> {
    self.handleEvents(receiveOutput: receiveOutput)
  }
  
  /// Performs the specified closures when publisher events occur.
  ///
  /// This is an overloaded version of ``Publisher/handleEvents(receiveSubscription:receiveOutput:receiveCompletion:receiveCancel:receiveRequest:)`` that only
  /// accepts a closure for the `receiveOutput` events. Use it to execute side effects while events pass down the pipeline.
  ///
  /// - Parameters:
  ///   - receiveOutput: A closure that executes when the publisher receives a value from the upstream publisher.
  /// - Returns: A publisher that performs the specified closures when publisher events occur.
  func handleEvents(_ receiveOutput: (@escaping () -> Void)) -> Publishers.HandleEvents<Self> {
    self.handleEvents { output in
      receiveOutput()
    }
  }
}
