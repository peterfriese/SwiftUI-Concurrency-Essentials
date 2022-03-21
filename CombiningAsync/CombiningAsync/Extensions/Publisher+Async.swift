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
  
  /// Executes a side effect.
  ///
  /// - Parameter handle: A closure that takes a parameter (the value received from the upstream publisher) and doesn't return a result.
  /// - Returns: A publisher that uses the provided closure to execute a side effect, and then returns the value received from the upsteam publisher.
  func perform<T>(_ handle: @escaping (Self.Output) -> Void) -> Publishers.Map<Self, T> where T == Self.Output {
    map { value in
      handle(value)
      return value
    }
  }
  
  /// Executes a side effect.
  ///
  /// - Parameter handle: A closure that doesn't take a parameter and doesn't return a result.
  /// - Returns: A publisher that uses the provided closure to execute a side effect, and then returns the value received from the upsteam publisher.
  func perform<T>(_ handle: @escaping () -> Void) -> Publishers.Map<Self, T> where T == Self.Output {
    map { value in
      handle()
      return value
    }
  }
  
//  func toggle<T>(_ value: Binding<Bool>) -> Publishers.Map<Self, T> where T == Self.Output {
//    return map { x in
//      value.wrappedValue.toggle()
//      return x
//    }
//  }
}
