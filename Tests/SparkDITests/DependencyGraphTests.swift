//
//  Copyright © 2025 SparkDI Contributors. All rights reserved.
//

#if canImport(Testing)
import Testing
#endif
import XCTest
@testable import SparkDI

#if canImport(Testing)
struct DependencyGraphTests {
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
    
    @Test func circularDependency() async throws {
        let dependencyContainer = DependencyContainer()
        
        try await dependencyContainer.register(
            type: ServiceA.self,
            factory: { args in
                guard let serviceB = args.first as? ServiceB else { fatalError("Invalid arguments") }
                
                return ServiceA(serviceB: serviceB)
            },
            scope: .transient
        )
        
        try await dependencyContainer.register(
            type: ServiceB.self,
            factory: { args in
                guard let serviceA = args.first as? ServiceA else { fatalError("Invalid arguments") }
                
                return ServiceB(serviceA: serviceA)
            },
            scope: .transient
        )
        
        let serviceA = await dependencyContainer.resolve(type: ServiceA.self)
        
        #expect(serviceA == nil)
    }

}
#endif
