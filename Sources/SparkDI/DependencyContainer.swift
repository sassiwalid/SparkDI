//  
//  Copyright © 2024 SparkDI Contributors. All rights reserved.
//
import Foundation

public enum Scope {

    case singleton

    case transient

}

public actor DependencyContainer {

    private struct Dependency {
        let factory: ([Any]) -> Any
        let scope: Scope
        let dependencyTypes: [Any.Type]
    }

    private var dependencies: [ObjectIdentifier: Dependency] = [:]

    private var sharedInstances: [ObjectIdentifier: Any] = [:]
    
    private var dependencyGraph: [ObjectIdentifier: Set<ObjectIdentifier>] = [:]

    public init() {}

    public func register<T>(
        type: T.Type,
        factory: @escaping ([Any]) -> T,
        scope: Scope = .transient
    ) async {
        
        await TypeRegistry.shared.register(type: T.self)
        
        let key = ObjectIdentifier(type)
        
        let mirror = DependencyMirror(reflecting: factory)
        
        let dependencyTypes = mirror.argumentTypes
        
        for dependencyType in dependencyTypes {
            await TypeRegistry.shared.register(type: dependencyType)
            
        }
        
        let dependencyIds = Set(dependencyTypes.map { ObjectIdentifier($0) })
        
        
        dependencies[key] = Dependency(
            factory: factory,
            scope: scope,
            dependencyTypes: dependencyTypes
        )
        
        dependencyGraph[key] = dependencyIds
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
