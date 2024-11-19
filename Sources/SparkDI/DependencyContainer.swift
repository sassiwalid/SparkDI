//  
//  Copyright © 2024 SparkDI Contributors. All rights reserved.
//
import Foundation

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
    
    private let lock = NSLock()

    public init() {}

    public func register<T>(
        type: T.Type,
        factory: @escaping ([Any]) -> T,
        scope: Scope = .transient
    ) {
        let key = ObjectIdentifier(type)

        lock.lock()

        dependencies[key] = Dependency(
            factory: factory,
            scope: scope
        )

        lock.unlock()

    }
    
    public func resolve<T>(
        type: T.Type,
        arguments: Any...
    ) -> T? {
    
        let key = ObjectIdentifier(type)

        guard let dependency = dependencies[key] else { return nil }

        switch dependency.scope {

        case .singleton:

            if let sharedInstance = sharedInstances[key] as? T {
                return sharedInstance
            }

            let sharedInstance = dependency.factory(arguments) as? T

            sharedInstances[key] = sharedInstance

            return sharedInstance

        case .transient:

            return dependency.factory(arguments) as? T
        }

    }

}
