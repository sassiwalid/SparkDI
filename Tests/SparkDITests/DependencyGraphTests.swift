//
//  Copyright © 2025 SparkDI Contributors. All rights reserved.
//

#if canImport(Testing)
import Testing
#endif
import XCTest
@testable import SparkDI

class ServiceA{
    let serviceB: ServiceB
    init(serviceB: ServiceB) {
        self.serviceB = serviceB
    }
}
class ServiceB {
    let serviceA: ServiceA
    init(serviceA: ServiceA) {
        self.serviceA = serviceA
    }
}

#if canImport(Testing)

struct DependencyGraphTesting {
    
    @Test func circularDependency() async throws {
        let dependencyContainer = DependencyContainer()
        do {
            try await dependencyContainer.register(
                type: ServiceA.self,
                factory: { args in
                    guard let serviceB = args.first as? ServiceB else { fatalError("Invalid arguments") }
                    
                    return ServiceA(serviceB: serviceB)
                },
                argumentsTypes: [ServiceB.self],
                scope: .transient
            )
            
            try await dependencyContainer.register(
                type: ServiceB.self,
                factory: { args in
                    guard let serviceA = args.first as? ServiceA else { fatalError("Invalid arguments") }
                    
                    return ServiceB(serviceA: serviceA)
                },
                argumentsTypes: [ServiceA.self],
                scope: .transient
            )

            Issue.record("Should have thrown circular dependency error")

        } catch let error as DependencyError {

            switch error {

            case .circularDependency:

                break

            default:

                Issue.record("Wrong error type: expected circular dependency")
            }
        } catch {

            Issue.record("Unexpected error: \(error)")
        }
    }

}
#endif
class DependencyGraphTests: XCTestCase {
    func testCircularDependency() async throws {
        let dependencyContainer = DependencyContainer()
        do {
            try await dependencyContainer.register(
                type: ServiceA.self,
                factory: { args in
                    guard let serviceB = args.first as? ServiceB else { fatalError("Invalid arguments") }
                    
                    return ServiceA(serviceB: serviceB)
                },
                argumentsTypes: [ServiceB.self],
                scope: .transient
            )
            
            try await dependencyContainer.register(
                type: ServiceB.self,
                factory: { args in
                    guard let serviceA = args.first as? ServiceA else { fatalError("Invalid arguments") }
                    
                    return ServiceB(serviceA: serviceA)
                },
                argumentsTypes: [ServiceA.self],
                scope: .transient
            )

            XCTFail("Should have thrown circular dependency error")

        } catch let error as DependencyError {

            switch error {

            case .circularDependency:

                break

            default:

                XCTFail("Wrong error type: expected circular dependency")
            }
        } catch {

            XCTFail("Unexpected error: \(error)")
        }
    }

}
