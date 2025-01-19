//
//  Copyright © 2025 SparkDI Contributors. All rights reserved.
//

@testable import SparkDI

class ComplexServiceB: Injectable {
    @Dependency var serviceC: ServiceC

    @Dependency var serviceD: ServiceD
    
    init(_ assembler: Assembler) {
        _serviceC = Dependency(assembler)

        _serviceD = Dependency(assembler)
    }
    
    func resolveDependencies() async throws {
        try await _serviceC.resolve()
        
        try await _serviceD.resolve()
    }
    
}
