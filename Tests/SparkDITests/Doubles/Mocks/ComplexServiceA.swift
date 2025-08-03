//
//  Copyright © 2025 SparkDI Contributors. All rights reserved.
//

@testable import SparkDI

final class ComplexServiceA: Injectable, @unchecked Sendable {
    @Dependency var serviceB: ComplexServiceB

    @Dependency var serviceC: ServiceC
    
    init(_ assembler: Assembler) {
        _serviceB = Dependency(assembler)

        _serviceC = Dependency(assembler)
    }
    
    func resolveDependencies() throws {
        try _serviceB.resolve()

        try _serviceC.resolve()
    }
    
}
