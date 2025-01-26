//  
//  Copyright © 2024 SparkDI Contributors. All rights reserved.
//
import Foundation

protocol Injectable {
    func resolveDependencies() async throws
}

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
    
    private var resolvedInstances: Set<ObjectIdentifier> = []

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
    }
    
    public func resolve<T>(
        type: T.Type,
        arguments: Any...
    ) async throws -> T {
        let key = ObjectIdentifier(type)
        
        guard !resolvedInstances.contains(key) else {
            return try await resolveSingle(type: type,arguments: arguments)
        }
        
        resolvedInstances.insert(key)
        
        defer { resolvedInstances.remove(key) }
        
        let instance = try await resolveSingle(type: type,arguments: arguments)
        
        if let injectableInstance = instance as? Injectable {
            try await injectableInstance.resolveDependencies()
        }
        
        return instance
    }
 
    public func resolveSingle<T>(
        type: T.Type,
        arguments: Any...
    ) async throws -> T {
    
        let key = ObjectIdentifier(type)
        
        guard let dependency = dependencies[key] else {
            throw DependencyError.dependencyNotFound(type: type)
        }
        
        try detectCircularDependencies(for: type)

        switch dependency.scope {

        case .singleton:

            if let sharedInstance = sharedInstances[key] as? T {
                return sharedInstance
            }

            guard let sharedInstance = dependency.factory(arguments) as? T else {
                throw DependencyError.resolutionFailed(type: type)
            }

            sharedInstances[key] = sharedInstance

            return sharedInstance

        case .transient:
            
            guard let instance = dependency.factory(arguments) as? T else {
                throw DependencyError.resolutionFailed(type: type)
            }

            return instance
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
                    if let dependencyTypes = dependencies[dependencyId]?.dependencyTypes {
                        for depType in dependencyTypes {
                            try depthFirstSearch(depType)
                        }
                    }
                }
            }
            
            stack.remove(currentId)

        }

        try depthFirstSearch(type)
    }

}
