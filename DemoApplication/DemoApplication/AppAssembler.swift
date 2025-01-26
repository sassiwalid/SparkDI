//
//  Copyright © 2025 SparkDI Contributors. All rights reserved.
//

import SparkDI

class AppAssembler {
    static let container = DependencyContainer()

    private static let assembler = Assembler(container: container)

    static let shared = AppAssembler()
    
    static func initialize() async throws {

        try await AppAssembler.container.register(type: String.self) { _ in "Hello, World!" }
    }

}
