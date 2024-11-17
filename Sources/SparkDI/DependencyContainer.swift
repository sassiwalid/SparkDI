//  
//  Copyright © 2024 SparkDI Contributors. All rights reserved.
//

public enum Scope {

    case singleton

    case transient

}

public final class DependencyContainer {

    private struct Dependency {
        let factory: ([Any]) -> Any
        let scope: Scope
    }

    private var dependencies: [ObjectIdentifier: Dependency] = [:]

    private var sharedInstances: [ObjectIdentifier: Any] = [:]

    public init() {}

    public func register<T>(
        type: T.Type,
        factory: @escaping ([Any]) -> T,
        scope: Scope = .transient
    ) {
        let key = ObjectIdentifier(type)

        dependencies[key] = Dependency(
            factory: factory,
            scope: scope
        )
    }
    
    public func resolve<T>(
        type: T.Type,
        arguments: Any...
    ) -> T? {
        let key = ObjectIdentifier(type)

        if let dependency = dependencies[key] {

            switch dependency.scope {

            case .singleton:

                if let shared = sharedInstances[key] as? T {
                    return shared
                }
                
                let instance = dependency.factory(arguments) as? T
                
                sharedInstances[key] = instance
                
                return instance
                
            case .transient:
                
                return dependency.factory(arguments) as? T
            }
        }

        return nil

    }
}
