//
//  SignalProducerSpec.swift
//  WolmoCore
//
//  Created by Francisco Depascuali on 7/15/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import Quick
import Nimble
import ReactiveSwift
import WolmoReactiveCore

class MockParentClass {
    let name: String

    init(name: String) { self.name = name }
}
final class MockChild1Class: MockParentClass { }
final class MockChild2Class: MockParentClass { }

public class SignalProducerSpec: QuickSpec {

    override public func spec() {
        
        describe("#dropError") {

            context("When dropping an error") {

                var producer: SignalProducer<(), NSError>!
                var property: MutableProperty<String>!
                var converted: SignalProducer<(), Never>!

                beforeEach {
                    property = MutableProperty("")
                    producer = property.producer.skip(first: 1).flatMap(.concat) { value -> SignalProducer<(), NSError> in
                        if (value.isEmpty) {
                            return SignalProducer(error: NSError(domain: "", code: 0, userInfo: [:]))
                        } else {
                            return SignalProducer(value: ())
                        }
                    }
                    converted = producer.dropError()
                }

                it("should ignore the error and complete") { waitUntil { done in
                    converted.collect().startWithValues {
                        expect($0).to(beEmpty())
                        done()
                    }
                    property.value = ""
                }}

                it("should not ignore a value") { waitUntil { done in
                    converted.startWithValues {
                        done()
                    }
                    property.value = "value"
                }}

            }

        }

        describe("#liftError") {

            context("When lifting an error") {

                var producer: SignalProducer<(), NSError>!
                var property: MutableProperty<String> = MutableProperty("")

                beforeEach {
                    property = MutableProperty("")
                    producer = property.producer.skip(first: 1).flatMap(.concat) { value -> SignalProducer<(), NSError> in
                        if (value.isEmpty) {
                            return SignalProducer(error: NSError(domain: "", code: 0, userInfo: [:]))
                        } else {
                            return SignalProducer(value: ())
                        }
                    }
                }

                it("should ignore the error and complete") { waitUntil { done in
                    let converted: SignalProducer<(), MyError> = producer.liftError()

                    converted.collect().startWithResult {
                        switch $0 {
                        case .success(let value):
                            expect(value).to(beEmpty())
                            done()
                        case .failure: break
                        }
                    }
                    property.value = ""
                }}

                it("should not ignore a value") { waitUntil { done in
                    let converted: SignalProducer<(), MyError> = producer.liftError()

                    converted.startWithResult {
                        switch $0 {
                        case .success: done()
                        case .failure: break
                        }
                    }
                    property.value = "value"
                }}

            }

        }
        
        describe("#onValue") {
            
            context("when sending a value") {
                
                it("should perform the given side effects") { waitUntil { done in
                    let producer = SignalProducer<(), NSError> { observer, _ in
                        observer.send(value: ())
                    }
                    producer.onValue { done() }.start()
                    }
                }
                
            }
            
        }
        
        describe("#onStarted") {
            
            context("when starting a producer") {
                
                it("should perform the given side effects") { waitUntil { done in
                    let producer = SignalProducer<(), NSError> { observer, _ in }
                    producer.onStarted { done() }.start()
                    }
                }
                
            }
            
        }
        
        describe("#onStarting") {
            
            context("when starting a producer") {
                
                it("should perform the given side effects") { waitUntil { done in
                    let producer = SignalProducer<(), NSError> { observer, _ in }
                    producer.onStarting { done() }.start()
                    }
                }
                
            }
            
        }
        
        describe("#onError") {
            
            context("when sending an error") {
                
                it("should perform the given side effects") { waitUntil { done in
                    let producer = SignalProducer<(), NSError> { observer, _ in
                        observer.send(error: NSError(domain: "", code: 0, userInfo: [:]))
                    }
                    producer.onError { _ in done() }.start()
                    }
                }
                
            }
            
        }
        
        describe("#onTerminated") {
            
            context("when sending an error") {
                
                it("should perform the given side effects") { waitUntil { done in
                    let producer = SignalProducer<(), NSError> { observer, _ in
                        observer.send(error: NSError(domain: "", code: 0, userInfo: [:]))
                    }
                    producer.onTerminated { done() }.start()
                    }
                }
                
            }
            
            context("when sending completed") {
                
                it("should perform the given side effects") { waitUntil { done in
                    let producer = SignalProducer<(), NSError> { observer, _ in
                        observer.sendCompleted()
                    }
                    producer.onTerminated { done() }.start()
                    }
                }
                
            }
            
            context("when disposing the producer") {
                
                it("should perform the given side effects") { waitUntil { done in
                    let producer = SignalProducer<(), NSError> { observer, _ in }
                    producer.onTerminated { done() }.start().dispose()
                    }
                }
                
            }
            
        }
        
        describe("#onCompleted") {
            
            context("when sending completed") {
                
                it("should perform the given side effects") { waitUntil { done in
                    let producer = SignalProducer<(), NSError> { observer, _ in
                        observer.sendCompleted()
                    }
                    producer.onCompleted { done() }.start()
                    }
                }
                
            }
            
        }
        
        describe("#onDisposed") {
            
            context("when disposing the producer") {
                
                it("should perform the given side effects") { waitUntil { done in
                    let producer = SignalProducer<(), NSError> { observer, _ in }
                    producer.onDisposed { done() }.start().dispose()
                    }
                }
                
            }
            
        }
        
        describe("#onInterrupted") {
            
            context("when interrupting the producer") {
                
                it("should perform the given side effects") { waitUntil { done in
                    let producer = SignalProducer<(), NSError> { observer, _ in
                        observer.sendInterrupted()
                    }
                    producer.onInterrupted { done() }.start()
                    }
                }
                
            }
            
        }
        
        describe("#toResultSignalProducer") {

            context("When sending a value") {
                
                it("should send on the value wrapped") { waitUntil { done in
                    let producer = SignalProducer<(), NSError> { observer, _ in
                        observer.send(value: ())
                        observer.sendCompleted()
                    }
                    let converted = producer.toResultSignalProducer()
                    converted.collect().startWithValues {
                        expect($0.count).to(equal(1))
                        done()
                    }
                }}
                
            }
            
            context("When sending an error") {
                
                it("should send on the error as a wrapped value") { waitUntil { done in
                    let producer = SignalProducer<(), NSError> { observer, _ in
                        observer.send(error: NSError(domain: "", code: 0, userInfo: [:]))
                    }
                    let converted = producer.toResultSignalProducer()
                    converted.collect().startWithValues {
                        expect($0.count).to(equal(1))
                        done()
                    }
                }}
                
            }
            
            context("When sending values and errors") {
                
                it("should send on everything wrapped up until it completes") { waitUntil { done in
                    let producer = SignalProducer<(), NSError> { observer, _ in
                        observer.send(value: ())
                        observer.send(error: NSError(domain: "", code: 0, userInfo: [:]))
                        observer.send(value: ())
                    }
                    let converted = producer.toResultSignalProducer()
                    converted.collect().startWithValues {
                        expect($0.count).to(equal(2))
                        done()
                    }
                }}
                
            }
            
        }

        describe("#filterType") {

            context("When the type is 'invalid'") {

                it("shouldn't send any value") { waitUntil { done in
                    let producer = SignalProducer<(), Never> { observer, _ in
                        observer.send(value: ())
                        observer.sendCompleted()
                    }
                    let converted: SignalProducer<UIViewController, Never> = producer.filterType()
                    converted.on(completed: { done() },
                                 value: { _ in fail() }).start()

                }}

            }

            context("When the type is 'valid'") {

                context("when there are values of that type") {

                    it("should send those values") { waitUntil { done in
                        let producer = SignalProducer<MockParentClass, Never> { observer, _ in
                            observer.send(value: MockChild1Class(name: "1"))
                            observer.send(value: MockChild2Class(name: "2"))
                            observer.sendCompleted()
                        }
                        let converted: SignalProducer<MockChild1Class, Never> = producer.filterType()
                        converted.collect().startWithValues {
                            expect($0.count).to(equal(1))
                            expect($0.first!.name).to(equal("1"))
                            done()
                        }
                    }}

                }

                context("when there aren't values of that type") {

                    it("shouldn't send any value") { waitUntil { done in
                        let producer = SignalProducer<MockParentClass, Never> { observer, _ in
                            observer.send(value: MockChild2Class(name: "1"))
                            observer.send(value: MockChild2Class(name: "2"))
                            observer.sendCompleted()
                        }
                        let converted: SignalProducer<MockChild1Class, Never> = producer.filterType()
                        converted.on(completed: { done() },
                                     value: { _ in fail() }).start()
                    }}

                }

            }

        }

        describe("#skipNotNil") {

            context("when there are non-nil values") {

                it("shouldn't send those values") { waitUntil { done in
                    let producer = SignalProducer<Int?, Never> { observer, _ in
                        observer.send(value: 3)
                        observer.send(value: .none)
                        observer.sendCompleted()
                    }
                    let converted = producer.skipNotNil()
                    converted.collect().startWithValues {
                        expect($0).to(equal([.none]))
                        done()
                    }
                }}

            }

            context("when there aren't non-nil values") {

                it("should send all values") { waitUntil { done in
                    let producer = SignalProducer<Int?, Never> { observer, _ in
                        observer.send(value: .none)
                        observer.send(value: .none)
                        observer.sendCompleted()
                    }
                    let converted = producer.skipNotNil()
                    converted.collect().startWithValues {
                        expect($0).to(equal([.none, .none]))
                        done()
                    }
                }}

            }

        }

        
        describe("#filterErrors") {
            
            context("When sending a success value") {
                
                it("shouldn't send on the value") { waitUntil { done in
                    let producer = SignalProducer<Result<(), NSError>, Never> { observer, _ in
                        observer.send(value: .success(()))
                        observer.sendCompleted()
                    }
                    let converted = producer.filterErrors()
                    converted.collect().startWithValues {
                        expect($0.count).to(equal(0))
                        done()
                    }
                }}
                
            }
            
            context("When sending a failure value") {
                
                it("should send on the error") { waitUntil { done in
                    let producer = SignalProducer<Result<(), NSError>, Never> { observer, _ in
                        observer.send(value: .failure(NSError(domain: "", code: 0, userInfo: [:])))
                        observer.sendCompleted()
                    }
                    let converted = producer.filterErrors()
                    converted.collect().startWithValues {
                        expect($0.count).to(equal(1))
                        done()
                    }
                }}
                
            }
            
        }
        
    }
    
}
