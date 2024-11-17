//
//  Copyright © 2024 SparkDI Contributors. All rights reserved.
//
import Foundation

public final class Assembler {
    private let container: DependencyContainer
    
    public init(container: DependencyContainer) {
        self.container = container
    }
    
    public func apply(modules: [Module]) {
        modules.forEach { $0.registerDependencies(in: container) }
    }
    
    public func resolve<T>(_ type: T.Type, arguments: Any...) -> T? {
        container.resolve(type: type,arguments: arguments)
    }
}
