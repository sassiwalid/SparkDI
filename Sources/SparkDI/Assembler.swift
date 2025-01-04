//  
//  Copyright © 2024 SparkDI Contributors. All rights reserved.
//

import Foundation

public final class Assembler {

    let container: DependencyContainer

    public init(container: DependencyContainer) {
        self.container = container
    }

    public func apply(modules: [Module]) async throws {

        for module in modules {
            try await module.registerDependencies(in: container)
        }

    }

    public func resolve<T>(
        _ type: T.Type,
        arguments: Any...
    ) async -> T? {

        await container.resolve(
            type: type,
            arguments: arguments
        )

    }
}
