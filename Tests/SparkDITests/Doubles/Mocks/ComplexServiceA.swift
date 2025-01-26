//
//  Copyright © 2025 SparkDI Contributors. All rights reserved.
//

@testable import SparkDI

class ComplexServiceA: Injectable {
    @Dependency var serviceB: ComplexServiceB

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
