//  
//  Copyright © 2024 SparkDI Contributors. All rights reserved.
//

@testable import SparkDI

struct UserModule: Module {

    func registerDependencies(in container: SparkDI.DependencyContainer) async  {
        await container.register(
            type: UserServiceDummy.self,
            factory: { _ in
                UserServiceDummy()
            },
            scope: .transient)
    }

}
