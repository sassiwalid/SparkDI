//
//  Copyright © 2025 SparkDI Contributors. All rights reserved.
//

@testable import SparkDI

final class ServiceD: Injectable,  @unchecked Sendable {
   @Dependency var serviceA: ComplexServiceA

   init(_ assembler: Assembler) {
       _serviceA = Dependency(assembler)
   }
    
    func resolveDependencies() throws {
        try _serviceA.resolve()
    }
}
