//
//  Copyright © 2025 SparkDI Contributors. All rights reserved.
//

@testable import SparkDI

class ServiceD: Injectable {
   @Dependency var serviceA: ComplexServiceA
   init(_ assembler: Assembler) {
       _serviceA = Dependency(assembler)
   }
    
    func resolveDependencies() async throws {
        try await _serviceA.resolve()
    }
}
