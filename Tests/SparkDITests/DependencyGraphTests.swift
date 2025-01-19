//
//  Copyright © 2025 SparkDI Contributors. All rights reserved.
//

#if canImport(Testing)
import Testing
#endif
import XCTest
@testable import SparkDI

#if canImport(Testing)

struct DependencyGraphTesting {
    
    @Test func circularDependency() async throws {
        let dependencyContainer = DependencyContainer()
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

        do {
            _ = try await dependencyContainer.resolve(type: ServiceA.self)

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
        do {
            _ = try await dependencyContainer.resolve(type: ServiceA.self)
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

    func testPropertyWrapperCircularDependency() async throws {
        let container = DependencyContainer()

        let assembler = Assembler(container: container)

        try await container.register(
            type: ServiceADependency.self,
            factory: {_ in
                print("Creating ServiceA")
                return ServiceADependency(assembler)
            },
            argumentsTypes: [ServiceBDependency.self]
        )

        try await container.register(
            type: ServiceBDependency.self,
            factory: {_ in
                print("Creating ServiceB")
                return ServiceBDependency(assembler)
            },
            argumentsTypes: [ServiceADependency.self]
        )

        do {
            let serviceA = try await container.resolve(type: ServiceADependency.self)
            print("Before resolving dependencies")
            try await serviceA.resolveDependencies()
            print("After resolving dependencies")

        } catch let error as DependencyError {

            switch error {

            case .circularDependency:

                break

            default:
                
                XCTFail("Wrong error type: expected circular dependency")
            }
        }

    }

}

fileprivate class ServiceA {
    let serviceB: ServiceB
    init(serviceB: ServiceB) {
        self.serviceB = serviceB
    }
}
fileprivate class ServiceB {
    let serviceA: ServiceA
    init(serviceA: ServiceA) {
        self.serviceA = serviceA
    }
}

fileprivate class ServiceADependency: Injectable {
    @Dependency var serviceB: ServiceBDependency
    
    init(_ assembler: Assembler) {
        _serviceB = Dependency(assembler)
    }
    
    func resolveDependencies() async throws {
        try await _serviceB.resolve()
    }
}

fileprivate class ServiceBDependency: Injectable {
    @Dependency var serviceA: ServiceADependency
    
    init(_ assembler: Assembler) {
        _serviceA = Dependency(assembler)
    }
    
    func resolveDependencies() async throws {
        try await _serviceA.resolve()
    }
}
