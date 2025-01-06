//  
//  Copyright © 2024 SparkDI Contributors. All rights reserved.
//
import Foundation

public enum Scope {

    case singleton

    case transient

}

public enum DependencyError: Error {

    case circularDependency
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
        argumentsTypes: [Any.Type] = [],
        scope: Scope = .transient
    ) async throws {
        
        await TypeRegistry.shared.register(type: T.self)
        
        let key = ObjectIdentifier(type)
        
        for dependencyType in argumentsTypes {
            await TypeRegistry.shared.register(type: dependencyType)
            
        }

        let dependencyIds = Set(argumentsTypes.map { ObjectIdentifier($0) })
        
        
        dependencies[key] = Dependency(
            factory: factory,
            scope: scope,
            dependencyTypes: argumentsTypes
        )
        
        dependencyGraph[key] = dependencyIds
        
        try detectCircularDependencies(for: type)
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

    private func detectCircularDependencies(for type: Any.Type) throws {

        var visited: Set<ObjectIdentifier> = []

        var stack: Set<ObjectIdentifier> = []

        func depthFirstSearch(_ currentType: Any.Type) throws {

            let currentId = ObjectIdentifier(currentType)

            if stack.contains(currentId) {
                throw DependencyError.circularDependency
            }

            if visited.contains(currentId) {
                return
            }
            
            visited.insert(currentId)

            stack.insert(currentId)

            if let dependenciesId = dependencyGraph[currentId] {
                for dependencyId in dependenciesId {
                    if let dependencyType = dependencies[dependencyId]?.dependencyTypes.first {
                        try depthFirstSearch(dependencyType)
                    }
                }
            }
            
            stack.remove(currentId)

        }

        try depthFirstSearch(type)
    }

}
