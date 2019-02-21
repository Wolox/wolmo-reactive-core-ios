//
//  SignalSpec.swift
//  WolmoCore
//
//  Created by Francisco Depascuali on 7/15/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import Quick
import Nimble
import ReactiveSwift
import WolmoReactiveCore

enum MyError: Error {
    case someError
}

public class SignalSpec: QuickSpec {
    
    override public func spec() {
        
        describe("#dropError") {

            context("When dropping an error") {

                var signal: Signal<(), NSError>!
                var observer: Signal<(), NSError>.Observer!
                var converted: Signal<(), Never>!

                beforeEach {
                    let (_signal, _observer) = Signal<(), NSError>.pipe()
                    signal = _signal
                    observer = _observer
                    converted = signal.dropError()
                }

                it("should ignore the error and complete") { waitUntil { done in
                    converted.collect().observeValues {
                        expect($0).to(beEmpty())
                        done()
                    }
                    observer.send(error: NSError(domain: "", code: 0, userInfo: [:]))
                }}

                it("should not ignore a value") { waitUntil { done in
                    converted.collect().observeValues {
                        expect($0.count).to(equal(2))
                        done()
                    }
                    observer.send(value: ())
                    observer.send(value: ())
                    observer.sendCompleted()
                }}

            }

        }

        describe("#liftError") {

            context("When lifting an error") {

                var signal: Signal<Int, NSError>!
                var observer: Signal<Int, NSError>.Observer!
                var converted: Signal<Int, MyError>!

                beforeEach {
                    let (_signal, _observer) = Signal<Int, NSError>.pipe()
                    signal = _signal
                    observer = _observer
                    converted = signal.liftError()
                }

                it("should ignore the error and complete") { waitUntil { done in
                    converted.collect().observeResult {
                        switch $0 {
                        case .success(let value):
                            expect(value).to(beEmpty())
                            done()
                        case .failure: break
                        }
                    }
                    observer.send(error: NSError(domain: "", code: 0, userInfo: [:]))
                }}

                it("should not ignore a value") { waitUntil { done in
                    converted.collect().observeResult {
                        switch $0 {
                        case .success(let value):
                            expect(value.count).to(equal(2))
                            done()
                        case .failure: break
                        }
                    }
                    observer.send(value: 2)
                    observer.send(value: 1)
                    observer.sendCompleted()
                }}

            }

        }
        
        describe("#toResultSignal") {
            
            var signal: Signal<(), NSError>!
            var observer: Signal<(), NSError>.Observer!
            var converted: Signal<Result<(), NSError>, Never>!
            
            beforeEach {
                let (_signal, _observer) = Signal<(), NSError>.pipe()
                signal = _signal
                observer = _observer
                converted = signal.toResultSignal()
            }
            
            context("When sending a value") {
                
                it("should send on the value wrapped") { waitUntil { done in
                    converted.collect().observeValues {
                        expect($0.count).to(equal(1))
                        done()
                    }
                    observer.send(value: ())
                    observer.sendCompleted()
                }}
                
            }
            
            context("When sending an error") {
                
                it("should send on the error as a wrapped value") { waitUntil { done in
                    converted.collect().observeValues {
                        expect($0.count).to(equal(1))
                        done()
                    }
                    observer.send(error: NSError(domain: "", code: 0, userInfo: [:]))
                }}
                
            }
            
            context("When sending values and errors") {
                
                it("should send on everything wrapped up until it completes") { waitUntil { done in
                    converted.collect().observeValues {
                        expect($0.count).to(equal(2))
                        done()
                    }
                    observer.send(value: ())
                    observer.send(error: NSError(domain: "", code: 0, userInfo: [:]))
                    observer.send(value: ())
                }}
                
            }
            
        }

        describe("#filterType") {

            var signal: Signal<MockParentClass, Never>!
            var observer: Signal<MockParentClass, Never>.Observer!

            beforeEach {
                let (_signal, _observer) = Signal<MockParentClass, Never>.pipe()
                signal = _signal
                observer = _observer
            }

            context("When the type is 'invalid'") {

                var convertedInvalid: Signal<UIViewController, Never>!

                beforeEach {
                    convertedInvalid = signal.filterType()
                }

                it("shouldn't send any value") { waitUntil { done in
                    convertedInvalid.collect().observeValues {
                        expect($0.isEmpty).to(beTrue())
                        done()
                    }
                    observer.send(value: MockChild1Class(name: "1"))
                    observer.sendCompleted()
                }}

            }

            context("When the type is 'valid'") {

                var convertedValid: Signal<MockChild1Class, Never>!

                beforeEach {
                    convertedValid = signal.filterType()
                }

                context("when there are values of that type") {

                    it("should send those values") { waitUntil { done in
                        convertedValid.collect().observeValues {
                            expect($0.count).to(equal(1))
                            expect($0.first!.name).to(equal("1"))
                            done()
                        }
                        observer.send(value: MockChild1Class(name: "1"))
                        observer.send(value: MockChild2Class(name: "2"))
                        observer.sendCompleted()
                    }}

                }

                context("when there aren't values of that type") {

                    it("shouldn't send any value") { waitUntil { done in
                        convertedValid.collect().observeValues {
                            expect($0.isEmpty).to(beTrue())
                            done()
                        }
                        observer.send(value: MockChild2Class(name: "1"))
                        observer.send(value: MockChild2Class(name: "2"))
                        observer.sendCompleted()
                    }}

                }

            }

        }

        describe("#skipNotNil") {

            var signal: Signal<Int?, Never>!
            var observer: Signal<Int?, Never>.Observer!
            var converted: Signal<Int?, Never>!

            beforeEach {
                let (_signal, _observer) = Signal<Int?, Never>.pipe()
                signal = _signal
                observer = _observer
                converted = signal.skipNotNil()
            }

            context("when there are non-nil values") {

                it("shouldn't send those values") { waitUntil { done in
                    converted.collect().observeValues {
                        expect($0).to(equal([.none]))
                        done()
                    }
                    observer.send(value: .none)
                    observer.send(value: 7)
                    observer.sendCompleted()
                }}

            }
            
            context("when there aren't non-nil values") {
                
                it("should send all valuee") { waitUntil { done in
                    converted.collect().observeValues {
                        expect($0).to(equal([.none, .none]))
                        done()
                    }
                    observer.send(value: .none)
                    observer.send(value: .none)
                    observer.sendCompleted()
                }}

            }
            
        }
        
        describe("#filterValues") {
            
            var signal: Signal<Result<(), NSError>, Never>!
            var observer: Signal<Result<(), NSError>, Never>.Observer!
            var converted: Signal<(), Never>!
            
            beforeEach {
                let (_signal, _observer) = Signal<Result<(), NSError>, Never>.pipe()
                signal = _signal
                observer = _observer
                converted = signal.filterValues()
            }
            
            context("When sending a success value") {
                
                it("should send on the value") { waitUntil { done in
                    converted.collect().observeValues {
                        expect($0.count).to(equal(1))
                        done()
                    }
                    observer.send(value: .success(()))
                    observer.sendCompleted()
                }}
                
            }
            
            context("When sending a failure value") {
                
                it("shouldn't send on the error") { waitUntil { done in
                    converted.collect().observeValues {
                        expect($0.count).to(equal(0))
                        done()
                    }
                    observer.send(value: .failure(NSError(domain: "", code: 0, userInfo: [:])))
                    observer.sendCompleted()
                }}
            
            }
        
        }
        
        describe("#filterErrors") {
            
            var signal: Signal<Result<(), NSError>, Never>!
            var observer: Signal<Result<(), NSError>, Never>.Observer!
            var converted: Signal<NSError, Never>!
            
            beforeEach {
                let (_signal, _observer) = Signal<Result<(), NSError>, Never>.pipe()
                signal = _signal
                observer = _observer
                converted = signal.filterErrors()
            }
            
            context("When sending a success value") {
                
                it("shouldn't send on the value") { waitUntil { done in
                    converted.collect().observeValues {
                        expect($0.count).to(equal(0))
                        done()
                    }
                    observer.send(value: .success(()))
                    observer.sendCompleted()
                }}
                
            }
            
            context("When sending a failure value") {
                
                it("should send on the error") { waitUntil { done in
                    converted.collect().observeValues {
                        expect($0.count).to(equal(1))
                        done()
                    }
                    observer.send(value: .failure(NSError(domain: "", code: 0, userInfo: [:])))
                    observer.sendCompleted()
                }}
                
            }
            
        }
        
        describe("#onValue") {
            
            context("when sending a value") {
                
                it("should perform the given side effects") { waitUntil { done in
                    let (signal, observer) = Signal<(), NoError>.pipe()
                    signal.onValue { _ in done() }.observeValues { _ in }
                    observer.send(value: ())
                    }
                }
                
            }
            
        }
        
        describe("#onError") {
            
            context("when sending an error") {
                
                it("should perform the given side effects") { waitUntil { done in
                    let (signal, observer) = Signal<(), NSError>.pipe()
                    signal.onError { _ in done() }.observeResult { _ in }
                    observer.send(error: NSError(domain: "", code: 0, userInfo: [:]))
                    }
                }
                
            }
            
        }
        
        describe("#onTerminated") {
            
            context("when sending an error") {
                
                it("should perform the given side effects") { waitUntil { done in
                    let (signal, observer) = Signal<(), NSError>.pipe()
                    signal.onTerminated { done() }.observeResult { _ in }
                    observer.send(error: NSError(domain: "", code: 0, userInfo: [:]))
                    }
                }
                
            }
            
            context("when sending completed") {
                
                it("should perform the given side effects") { waitUntil { done in
                    let (signal, observer) = Signal<(), NSError>.pipe()
                    signal.onTerminated { done() }.observeResult { _ in }
                    observer.sendCompleted()
                    }
                }
                
            }
            
            context("when interrupting the signal") {
                
                it("should perform the given side effects") { waitUntil { done in
                    let (signal, observer) = Signal<(), NSError>.pipe()
                    signal.onTerminated { done() }.observeResult { _ in }
                    observer.sendInterrupted()
                    }
                }
                
            }
            // unlike the producer, disposing a signal doesn't terminate it, so we are not testing that case
            
        }
        
        describe("#onCompleted") {
            
            context("when interrupting the signal") {
                
                it("should perform the given side effects") { waitUntil { done in
                    let (signal, observer) = Signal<(), NSError>.pipe()
                    signal.onInterrupted { done() }.observeResult { _ in }
                    observer.sendInterrupted()
                    }
                }
                
            }
            
        }
        
        describe("#onInterrupted") {
            
            context("when interrupting ") {
                
                it("should perform the given side effects") { waitUntil { done in
                    let (signal, observer) = Signal<(), NSError>.pipe()
                    signal.onCompleted { done() }.observeResult { _ in }
                    observer.sendCompleted()
                    }
                }
                
            }
            
        }
        
        describe("#onDisposed") {
            
            context("when disposing the signal") {
                
                it("should perform the given side effects") { waitUntil { done in
                    let (signal, _) = Signal<(), NSError>.pipe()
                    signal.onDisposed { done() }.observeResult { _ in }?.dispose()
                    }
                }
                
            }
            
        }
        
    }
    
}
