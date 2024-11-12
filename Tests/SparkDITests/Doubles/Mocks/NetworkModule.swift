@testable import SparkDI
struct NetworkModule: Module {

    func registerDependencies(in container: SparkDI.DependencyContainer) {
        container.register(
            type: APIServiceDummy.self,
            factory: { _ in  APIServiceDummy()
            },
            scope: .singleton)
        
        container.register(
            type: NetworkManagerDummy.self,
            factory: { _ in  NetworkManagerDummy()
            },
            scope: .singleton)
        
    }

}
