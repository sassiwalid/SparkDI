//  
//  Copyright © 2024 SparkDI Contributors. All rights reserved.
//

import Testing
import Foundation

@testable import SparkDI

struct SparkDIConcurrentTests {
    @Test
    func ConcurrentWriteCrash() async throws {
        let container = DependencyContainer()
        
        await confirmation("…") { expectation in

            let iterations = 1000

            DispatchQueue.concurrentPerform(iterations: iterations) { index in
                Task {
                    try container.register(
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
                    _ = try container.resolve(type: String.self)
                }

            }

            expectation()
        }
    }
}
