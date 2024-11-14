//
//  Copyright © 2024 SparkDI Contributors. All rights reserved.
//
enum Scope {
    case singleton
    case transient
}

final class DependencyContainer {
    private var dependencies: [ObjectIdentifier: ([Any]) -> Any] = [:]

    private var sharedInstances: [ObjectIdentifier: Any] = [:]
    
    func register<T>(
        type: T.Type,
        factory: @escaping ([Any])-> T,
        scope: Scope = .transient
    ) {
        let key = ObjectIdentifier(type)
        
        dependencies[key] = factory
        
        if scope == .singleton {
            sharedInstances[key] = factory([])
        }
    }
    
    func resolve<T>(
        type: T.Type,
        arguments: Any...
    ) -> T? {
        let key = ObjectIdentifier(type)
        
        if let sharedInstance = sharedInstances[key] {
            return sharedInstance as? T
        }
        
        if let factory = dependencies[key] {
            return factory(arguments) as? T
        }
        
        return nil
        
    }
}
