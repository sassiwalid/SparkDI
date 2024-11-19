//
//  ConcurrentTests.swift
//  SparkDI
//
//  Created by Walid SASSI on 19/11/2024.
//

#if canImport(Testing)
import Testing
#endif
import XCTest
@testable import SparkDI

#if canImport(Testing)
struct SparkDIConcurrentTests {
    @Test
    func ConcurrentWriteCrash() async throws {
        let container = DependencyContainer()
        
        await confirmation("…") { expectation in

            let iterations = 1000

            let concurrentQueue = DispatchQueue(
                label: "com.sparkdi.concurrentQueue",
                attributes: .concurrent
            )

            DispatchQueue.concurrentPerform(iterations: iterations) { index in
                concurrentQueue.async { 
                    container.register(
                        type: String.self,
                        factory: { _ in
                            "instance \(index)"
                        },
                        scope: .transient
                    )
                }
            }

            expectation()
        }
    }
}
#endif

final class ConcurrentTests: XCTestCase {
    func testConcurrentWriteCrash() throws {
        let container = DependencyContainer()
        
        let expectation = XCTestExpectation(description: "Concurrent writes should cause crash (1000 iterations)")
        
        let iterations = 1000
        
        let concurrentQueue = DispatchQueue(
            label: "com.sparkdi.concurrentQueue",
            attributes: .concurrent
        )

        DispatchQueue.concurrentPerform(iterations: iterations) { index in
            concurrentQueue.async {
                container.register(
                    type: String.self,
                    factory: { _ in
                        "instance \(index)"
                    },
                    scope: .transient
                )
            }
        }
        
        expectation.fulfill()
        
        wait(for: [expectation], timeout: 5)
    }
}
