import XCTest
import enum Result.NoError
import ReactiveSwift
import RxSwift
import ReactiveKit
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

    /// ===============================================================

    func test_measure_ReactiveSwift_2() {
        measure {
            var counter : Int = 0
            let (signal, observer) = ReactiveSwift.Signal<Int, NoError>.pipe()

            for _ in 1..<100 {
                signal.observeValues { counter += $0 }
            }

            for i in 1..<100_000 {
                observer.send(value: i)
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

    /// ===============================================================

    func test_measure_ReactiveSwift_3() {
        measure {
            let (signal, observer) = ReactiveSwift.Signal<Int, NoError>.pipe()

            for _ in 1..<100 {
                signal.filter{ $0%2 == 0}.map(String.init).observeValues { _ in }
            }

            for i in 1..<100_000 {
                observer.send(value: i)
            }
        }
    }

    func test_measure_RxSwift_3() {
        measure {
            let variable = Variable(0)
            let o = variable.asObservable()

            for _ in 1..<100 {
                _ = o.filter{ $0%2 == 0}.map(String.init).subscribe(onNext: { _ in })
            }
            
            for i in 1..<100_000 {
                variable.value = i
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
            let v1 = Variable(0)
            let v2 = Variable(0)

            let o1 = v1.asObservable()
            let o2 = v2.asObservable()

            for _ in 1..<100 {
               _ = Observable.combineLatest([o1, o2])
                .subscribe(onNext: { _ in })
            }

            for i in 1..<1_000 {
                v1.value = i
                v2.value = i
            }
        }
    }

}
