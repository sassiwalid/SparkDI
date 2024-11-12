@testable import SparkDI

struct UserModule: Module {

    func registerDependencies(in container: SparkDI.DependencyContainer) {
        container.register(
            type: UserServiceDummy.self,
            factory: { _ in
                UserServiceDummy()
            },
            scope: .transient)
    }

}

