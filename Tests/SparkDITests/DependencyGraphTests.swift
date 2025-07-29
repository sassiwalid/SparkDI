//
//  Copyright © 2025 SparkDI Contributors. All rights reserved.
//

import Foundation
import Testing

@testable import SparkDI

struct DependencyGraphTesting {
    
    @Test func circularDependency() throws {
        let dependencyContainer = DependencyContainer()
            try dependencyContainer.register(
                type: ServiceA.self,
                factory: { args in
                    guard let serviceB = args.first as? ServiceB else { fatalError("Invalid arguments") }
                    
                    return ServiceA(serviceB: serviceB)
                },
                argumentsTypes: [ServiceB.self],
                scope: .transient
            )
            
            try dependencyContainer.register(
                type: ServiceB.self,
                factory: { args in
                    guard let serviceA = args.first as? ServiceA else { fatalError("Invalid arguments") }
                    
                    return ServiceB(serviceA: serviceA)
                },
                argumentsTypes: [ServiceA.self],
                scope: .transient
            )

        do {
            _ = try dependencyContainer.resolve(type: ServiceA.self)

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
    
    @Test func propertyWrapperCircularDependency() async throws {
        let container = DependencyContainer()

        let assembler = Assembler(container: container)
        
        final class ServiceADependency: Injectable, @unchecked Sendable {
            @Dependency var serviceB: ServiceBDependency
            
            init(_ assembler: Assembler) {
                _serviceB = Dependency(assembler)
            }
            
            func resolveDependencies() throws {
                try _serviceB.resolve()
            }
        }

        final class ServiceBDependency: Injectable, @unchecked Sendable {
            @Dependency var serviceA: ServiceADependency
            
            init(_ assembler: Assembler) {
                _serviceA = Dependency(assembler)
            }
            
            func resolveDependencies() throws {
                try _serviceA.resolve()
            }
        }


        try container.register(
            type: ServiceADependency.self,
            factory: {_ in ServiceADependency(assembler)},
            argumentsTypes: [ServiceBDependency.self]
        )

        try container.register(
            type: ServiceBDependency.self,
            factory: {_ in ServiceBDependency(assembler) },
            argumentsTypes: [ServiceADependency.self]
        )

        do {
            let serviceA = try container.resolve(type: ServiceADependency.self)

            try serviceA.resolveDependencies()

        } catch let error as DependencyError {

            switch error {

            case .circularDependency:

                break

            default:
                
                Issue.record("Wrong error type: expected circular dependency")
            }
        }

    }
    
    @Test func complexCircularDependency() async throws {
        let container = DependencyContainer()

        let assembler = Assembler(container: container)

       try assembler.container.register(
           type: ComplexServiceA.self,
           factory: { _ in ComplexServiceA(assembler) },
           argumentsTypes: [ServiceB.self, ServiceC.self]
       )
       
       try assembler.container.register(
           type: ComplexServiceB.self,
           factory: { _ in ComplexServiceB(assembler) },
           argumentsTypes: [ServiceC.self, ServiceD.self]
       )
       
       try assembler.container.register(
           type: ServiceC.self,
           factory: { _ in ServiceC() }
       )
       
       try assembler.container.register(
           type: ServiceD.self,
           factory: { _ in ServiceD(assembler) },
           argumentsTypes: [ServiceA.self]
       )
       
       do {
           let serviceA = try container.resolve(type: ComplexServiceA.self)

           try serviceA.resolveDependencies()

       } catch let error as DependencyError {
           switch error {

           case .circularDependency:

               break

           default:
               
               Issue.record("Wrong error type: expected circular dependency")
           }
       }
    }

    
    

}
