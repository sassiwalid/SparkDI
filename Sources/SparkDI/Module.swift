//  
//  Copyright © 2024 SparkDI Contributors. All rights reserved.
//

public protocol Module {

    func registerDependencies(in container: SparkDI.DependencyContainer) async throws

}
