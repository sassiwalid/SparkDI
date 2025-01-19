//
//  Copyright © 2025 SparkDI Contributors. All rights reserved.
//

#if canImport(Testing)
import Testing
#endif
import XCTest
@testable import SparkDI

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
        
        class ServiceADependency: Injectable {
            @Dependency var serviceB: ServiceBDependency
            
            init(_ assembler: Assembler) {
                _serviceB = Dependency(assembler)
            }
            
            func resolveDependencies() async throws {
                try await _serviceB.resolve()
            }
        }

        class ServiceBDependency: Injectable {
            @Dependency var serviceA: ServiceADependency
            
            init(_ assembler: Assembler) {
                _serviceA = Dependency(assembler)
            }
            
            func resolveDependencies() async throws {
                try await _serviceA.resolve()
            }
        }


        try await container.register(
            type: ServiceADependency.self,
            factory: {_ in ServiceADependency(assembler)},
            argumentsTypes: [ServiceBDependency.self]
        )

        try await container.register(
            type: ServiceBDependency.self,
            factory: {_ in ServiceBDependency(assembler) },
            argumentsTypes: [ServiceADependency.self]
        )

        do {
            let serviceA = try await container.resolve(type: ServiceADependency.self)

            try await serviceA.resolveDependencies()

        } catch let error as DependencyError {

            switch error {

            case .circularDependency:

                break

            default:
                
                XCTFail("Wrong error type: expected circular dependency")
            }
        }

    }
    
    func testComplexCircularDependency() async throws {
        let container = DependencyContainer()

        let assembler = Assembler(container: container)
           
        class ServiceD: Injectable {
           @Dependency var serviceA: ServiceA
           init(_ assembler: Assembler) {
               _serviceA = Dependency(assembler)
           }
            
            func resolveDependencies() async throws {
                try await _serviceA.resolve()
            }
       }
           
        class ServiceC: Injectable {
            init() { }
            
            func resolveDependencies() async throws {}
        }
           
        class ServiceB: Injectable {
            @Dependency var serviceC: ServiceC

            @Dependency var serviceD: ServiceD
            
            init(_ assembler: Assembler) {
                _serviceC = Dependency(assembler)

                _serviceD = Dependency(assembler)
            }
            
            func resolveDependencies() async throws {
                try await _serviceC.resolve()
                
                try await _serviceD.resolve()
            }
            
        }
           
        class ServiceA: Injectable {
            @Dependency var serviceB: ServiceB

            @Dependency var serviceC: ServiceC
            
            init(_ assembler: Assembler) {
                _serviceB = Dependency(assembler)

                _serviceC = Dependency(assembler)
            }
            
            func resolveDependencies() async throws {
                try await _serviceB.resolve()

                try await _serviceC.resolve()
            }
            
        }

       try await assembler.container.register(
           type: ServiceA.self,
           factory: { _ in ServiceA(assembler) },
           argumentsTypes: [ServiceB.self, ServiceC.self]
       )
       
       try await assembler.container.register(
           type: ServiceB.self,
           factory: { _ in ServiceB(assembler) },
           argumentsTypes: [ServiceC.self, ServiceD.self]
       )
       
       try await assembler.container.register(
           type: ServiceC.self,
           factory: { _ in ServiceC() }
       )
       
       try await assembler.container.register(
           type: ServiceD.self,
           factory: { _ in ServiceD(assembler) },
           argumentsTypes: [ServiceA.self]
       )
       
       do {
           let serviceA = try await container.resolve(type: ServiceA.self)

           try await serviceA.resolveDependencies()

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
