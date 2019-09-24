//
//  Signal.swift
//  WolmoCore
//
//  Created by Francisco Depascuali on 6/29/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import ReactiveSwift

// Can't extend ResultProtocol to EventProtocol.
// Now Result-valued signals can de materialized and dematerialized.
extension Result: EventProtocol {

    public var event: Signal<Value, Error>.Event {
        switch self {
        case .success(let value):
            return .value(value)
        case .failure(let error):
            return.failed(error)
        }
    }

}

public extension Signal {

    /**
     Ignores errors.
     This is usually useful when the `flatMap` operator is used and the outer
     signal has `NoError` error type and the inner one a different type of error.

     - returns: A signal with the same value type but with `NoError` as the error type
     */
    public func dropError() -> Signal<Value, Never> {
        return flatMapError { _ in SignalProducer<Value, Never>.empty }
    }

    /**
         Transforms a `Signal<Value, Error>` to `Signal<Value, NewError>`.
         This is usually useful when the `flatMap` operator is used and the outer
         signal has another error type and the inner one a different type of error.

         - returns: A signal with the same value type but with `NewError` as the error type
         - note: For transforming NoError to another error you can use `promoteError`
         - note: You can do this to avoid `.dropError().promoteError()` chaining
     */
    public func liftError<NewError>() -> Signal<Value, NewError> {
        return flatMapError { _ in SignalProducer<Value, NewError>.empty }
    }

    /**
        Transforms the `Signal<Value, Error>` to `Signal<Result<Value, Error>, NoError>`.
        This is usually useful when the `flatMap` triggers different signals
        which if failed shouldn't finish the whole result signal, stopping new signals
        from being triggered when a new value arrives at self.

        ```
        var loginSignal: Signal<(), NoError>

        loginSignal.flatMap(.Latest) { _ -> Signal<MyUser, MyError> in
            return authService.login()
        }
        ```

        It may be considered similar to the `events` signal of an `Action` (with only next and failed).
    */
    public func toResultSignal() -> Signal<Result<Value, Error>, Never> {
        return map { Result<Value, Error>.success($0) }
            .flatMapError { error -> SignalProducer<Result<Value, Error>, Never> in
                let errorValue = Result<Value, Error>.failure(error)
                return SignalProducer<Result<Value, Error>, Never>(value: errorValue)
        }
    }

    /**
         Filters stream and only passes through the values that respond
         to the specific type, as elements of that specific type.

         - returns: A signal with value type T and the same error type.
     */
    public func filterType<T>() -> Signal<T, Error> {
        return filterMap { $0 as? T }
        //Can't restrict T to conform/inherit-from Value
    }

}

public extension Signal where Value: OptionalProtocol {

    /**
     Skips all not-nil values, sending only the .none values through.
     */
    public func skipNotNil() -> Signal<Value, Error> {
        return filter { $0.optional == nil }
    }

}

public extension Signal where Value: ResultProtocol {

    /**
        Transforms a `Signal<ResultProtocol<Value2, Error2>, Error>` to `Signal<Value2, Error>`,
        ignoring all `Error2` events.

        It may be considered similar to the `values` signal of an `Action`.
    */
    public func filterValues() -> Signal<Value.Value, Error> {
        return filter {
            if $0.result.value != nil {
                return true
            }
            return false
        }.map { $0.result.value! }
    }

    /**
         Transforms a `Signal<ResultProtocol<Value2, Error2>, Error>` to `Signal<Error2, Error>`,
         ignoring all `Value2` events.

         It may be considered similar to the `errors` signal of an `Action`.
     */
    public func filterErrors() -> Signal<Value.Error, Error> {
        return filter {
            if $0.result.error != nil {
                return true
            }
            return false
        }.map { $0.result.error! }
    }

}

public extension Signal {

    /**
     - parameter handler: closure to execute upon value.

     Inject side effects to be performed upon a value event.
     */
    func onValue(_ handler: @escaping (Value) -> Void ) -> Signal {
        return on(value: handler)
    }

    /**
     - parameter handler: closure to execute upon error.

     Inject side effects to be performed upon an error event.
     */
    func onError(_ handler: @escaping (Error) -> Void ) -> Signal {
        return on(failed: handler)
    }

    /**
     - parameter handler: closure to execute upon signal disposal.

     Inject side effects to be performed upon disposing the signal.
     */
    func onDisposed(_ handler: @escaping () -> Void ) -> Signal {
        return on(disposed: handler)
    }

    /**
     - parameter handler: closure to execute upon Completion.

     Inject side effects to be performed upon a Completed event.
     */
    func onCompleted(_ handler: @escaping () -> Void ) -> Signal {
        return on(completed: handler)
    }

    /**
     - parameter handler: closure to execute upon Termination.

     Inject side effects to be performed upon a terminating event (interrupted, completed, error).
     */
    func onTerminated(_ handler: @escaping () -> Void ) -> Signal {
        return on(terminated: handler)
    }

    /**
     - parameter handler: closure to execute upon interruption.

     Inject side effects to be performed upon an interrupted event.
     */
    func onInterrupted(_ handler: @escaping () -> Void ) -> Signal {
        return on(interrupted: handler)
    }
}

public protocol ResultProtocol {
    associatedtype Value
    associatedtype Error: Swift.Error

    init(value: Value)
    init(error: Error)

    var result: Result<Value, Error> { get }
}

extension Result: ResultProtocol {

    /// Constructs a success wrapping a `value`.
    public init(value: Value) {
        self = .success(value)
    }

    /// Constructs a failure wrapping an `error`.
    public init(error: Error) {
        self = .failure(error)
    }

    public var result: Result<Value, Error> {
        return self
    }

    /// Returns the value if self represents a success, `nil` otherwise.
    public var value: Value? {
        switch self {
        case let .success(value): return value
        case .failure: return nil
        }
    }

    /// Returns the error if self represents a failure, `nil` otherwise.
    public var error: Error? {
        switch self {
        case .success: return nil
        case let .failure(error): return error
        }
    }
}
