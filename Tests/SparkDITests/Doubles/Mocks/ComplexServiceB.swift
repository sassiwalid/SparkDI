//
//  Copyright © 2025 SparkDI Contributors. All rights reserved.
//

@testable import SparkDI

final class ComplexServiceB: Injectable, @unchecked Sendable {
    @Dependency var serviceC: ServiceC

    @Dependency var serviceD: ServiceD
    
    init(_ assembler: Assembler) {
        _serviceC = Dependency(assembler)

        _serviceD = Dependency(assembler)
    }
    
    func resolveDependencies() throws {
        try _serviceC.resolve()
        
        try _serviceD.resolve()
    }
    
}
