//  
//  Copyright © 2024 SparkDI Contributors. All rights reserved.
//

@testable import SparkDI
struct NetworkModule: Module {

    func registerDependencies(in container: SparkDI.DependencyContainer) async throws {
        try await container.register(
            type: APIServiceDummy.self,
            factory: { _ in  APIServiceDummy()
            },
            scope: .singleton)
        
        try await container.register(
            type: NetworkManagerDummy.self,
            factory: { _ in  NetworkManagerDummy()
            },
            scope: .singleton)
        
    }

}
