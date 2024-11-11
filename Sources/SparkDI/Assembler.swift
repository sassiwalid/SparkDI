import Foundation

final class Assembler {
    private let container: DependencyContainer
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    func apply(modules: [Module]) {
        modules.forEach { $0.registerDependencies(in: container) }
    }
    
    func resolve<T>(_ type: T.Type, arguments: Any...) -> T? {
        container.resolve(type: type,arguments: arguments)
    }
}

