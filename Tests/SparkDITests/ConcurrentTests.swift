//  
//  Copyright © 2024 SparkDI Contributors. All rights reserved.
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

            DispatchQueue.concurrentPerform(iterations: iterations) { index in
                Task {
                    await container.register(
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
    
    func ConcurrentReadCrash() async throws {
        let container = DependencyContainer()
        
        await confirmation("…") { expectation in

            let iterations = 1000

            DispatchQueue.concurrentPerform(iterations: iterations) { index in
                Task {
                    _ = await container.resolve(type: String.self)
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

        DispatchQueue.concurrentPerform(iterations: iterations) { index in
            Task {
                await container.register(
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
    
    func testConcurrentReadCrash() throws {
        let container = DependencyContainer()
        
        let expectation = XCTestExpectation(description: "Concurrent read should cause crash (1000 iterations)")
        
        let iterations = 1000

        DispatchQueue.concurrentPerform(iterations: iterations) { index in
            Task {
                _ = await container.resolve(type: String.self)
    
            }
        }
        
        expectation.fulfill()
        
        wait(for: [expectation], timeout: 5)
    }
}
