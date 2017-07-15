import XCTest
import enum Result.NoError
import ReactiveSwift
import RxSwift
import ReactiveKit
import CwlSignal
@testable import TestingFRP

class TestingFRPTests: XCTestCase {

    func test_measure_ReactiveSwift_1() {
        measure {
            var counter : Int = 0

            let producer = SignalProducer<Int, NoError> { o, d in
                for i in 1..<100_000 {
                    o.send(value: i)
                }
            }

            producer.startWithValues { counter += $0 }
        }
    }

    func test_measure_RxSwift_1() {
        measure {
            var counter : Int = 0

            let observable = RxSwift.Observable<Int>.create { o in
                for i in 1..<100_000 {
                    o.onNext(i)
                }

                return Disposables.create()
            }

            _ = observable.subscribe(onNext: { counter += $0 })
        }
    }

    func test_measure_ReactiveKit_1() {
        measure {
            var counter : Int = 0
            let signal = ReactiveKit.Signal<Int, NoError> { o in
                for i in 1..<100_000 {
                    o.next(i)
                }

                return NonDisposable.instance
            }

            _ = signal.observeNext(with: { counter += $0 })
        }
    }

    func test_measure_CwlSignal_1() {
        measure {
            var counter : Int = 0
            let signal = CwlSignal.Signal<Int>.generate { input in
                if let input = input {
                    for i in 1..<100_000 {
                        input.send(value: i)
                    }
                }
            }

            _ = signal.subscribeValues { counter += $0 }
        }
    }

    /// ===============================================================

    func test_measure_ReactiveSwift_2() {
        measure {
            var counter : Int = 0
            let property = ReactiveSwift.MutableProperty<Int>(0)

            for _ in 1..<100 {
                property.producer.startWithValues { counter += $0 }
            }

            for i in 1..<100_000 {
                property.value = i
            }
        }
    }

    func test_measure_RxSwift_2() {
        measure {
            var counter : Int = 0
            let variable = Variable(0)

            for _ in 1..<100 {
                _ = variable.asObservable().subscribe(onNext: { counter += $0 })
            }

            for i in 1..<100_000 {
                variable.value = i
            }
        }
    }

    func test_measure_ReactiveKit_2() {
        measure {
            var counter : Int = 0
            let property = ReactiveKit.Property.init(0)

            for _ in 1..<100 {
                _ = property.observeNext { counter += $0 }
            }

            for i in 1..<100_000 {
                property.value = i
            }
        }
    }

    func test_measure_CwlSignal_2() {
        // CwlSignal does not have a `Property` entity, so we use its `replayLast`
        // counterpart.
        measure {
            var endpoints: [AnyObject] = []
            var counter : Int = 0
            let (input, output) = CwlSignal.Signal<Int>.create { $0.continuous() }

            let multicasted = output.multicast()
            for _ in 1..<100 {
                let e = multicasted.subscribeValues { counter += $0 }
                endpoints.append(e)
            }

            withExtendedLifetime(endpoints) {
                for i in 1..<100_000 {
                    input.send(value: i)
                }
            }
        }
    }

    /// ===============================================================

    func test_measure_ReactiveSwift_3() {
        measure {
            let (signal, observer) = ReactiveSwift.Signal<Int, NoError>.pipe()

            for _ in 1..<100 {
                signal.filterMap { $0 % 2 == 0 ? String($0) : nil }.observeValues { _ in }
            }

            for i in 1..<100_000 {
                observer.send(value: i)
            }
        }
    }

    func test_measure_RxSwift_3() {
        measure {
            let variable = RxSwift.PublishSubject<Int>()
            let o = variable.asObservable()

            for _ in 1..<100 {
                _ = o.filter{ $0%2 == 0}.map(String.init).subscribe(onNext: { _ in })
            }

            for i in 1..<100_000 {
                variable.onNext(i)
            }
        }
    }

    func test_measure_CwlSignal_3() {
        measure {
            var endpoints: [AnyObject] = []
            let (input, output) = CwlSignal.Signal<Int>.create()
            let multicasted = output.multicast()

            for _ in 1..<100 {
                let e = multicasted.filterMap { $0 % 2 == 0 ? String($0) : nil }.subscribeValues { _ in }
                endpoints.append(e)
            }

            withExtendedLifetime(endpoints) {
                for i in 1..<100_000 {
                    input.send(value: i)
                }
            }
        }
    }

    /// ===============================================================

    func test_measure_ReactiveSwift_4() {
        measure {
            let (s1, o1) = ReactiveSwift.Signal<Int, NoError>.pipe()
            let (s2, o2) = ReactiveSwift.Signal<Int, NoError>.pipe()

            for _ in 1..<100 {
                ReactiveSwift.Signal<Int, NoError>
                    .combineLatest([s1,s2])
                    .observeValues { _ in }
            }

            for i in 1..<1_000 {
                o1.send(value: i)
                o2.send(value: i)
            }
        }
    }

    func test_measure_RxSwift_4() {
        measure {
            let v1 = RxSwift.PublishSubject<Int>()
            let v2 = RxSwift.PublishSubject<Int>()

            let o1 = v1.asObservable()
            let o2 = v2.asObservable()

            for _ in 1..<100 {
               _ = Observable.combineLatest([o1, o2])
                .subscribe(onNext: { _ in })
            }

            for i in 1..<1_000 {
                v1.onNext(i)
                v2.onNext(i)
            }
        }
    }

    func test_measure_CwlSignal_4() {
        measure {
            var endpoints: [AnyObject] = []

            let (input1, output1) = CwlSignal.Signal<Int>.create()
            let (input2, output2) = CwlSignal.Signal<Int>.create()
            let multicasted1 = output1.multicast()
            let multicasted2 = output2.multicast()

            for _ in 1..<100 {
                let e = multicasted1.combineLatest(second: multicasted2) { $0 }.subscribeValues { _ in }
                endpoints.append(e)
            }

            withExtendedLifetime(endpoints) {
                for i in 1..<100_000 {
                    input1.send(value: i)
                    input2.send(value: i)
                }
            }
        }
    }
}
