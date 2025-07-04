//  
//  Copyright © 2024 SparkDI Contributors. All rights reserved.
//

import Testing

@testable import SparkDI

struct AssemblerTests {
    @Test func assemblerWithMultipleModules() async throws {
        /// GIVEN
        let container = DependencyContainer()
        let assembler = Assembler(container: container)
        try await assembler.apply(
            modules: [NetworkModule(), UserModule()]
        )

        /// WHEN

        // resolve Network module dependencies (singletons case)
        let apiService1 = try await container.resolve(type: APIServiceDummy.self)
        let apiService2 = try await container.resolve(type: APIServiceDummy.self)
        
        let networkManager1 = try await container.resolve(type: NetworkManagerDummy.self)
        let networkManager2 = try await container.resolve(type: NetworkManagerDummy.self)
        
        // resolve user module dependencies (new instance case)
        
        let userService1 = try await container.resolve(type: UserServiceDummy.self)
        let userService2 = try await container.resolve(type: UserServiceDummy.self)

        /// THEN

        #expect(apiService1 === apiService2)
        #expect(networkManager1 === networkManager2)
        #expect(userService1 !== userService2)
    }
}
