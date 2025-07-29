//  
//  Copyright © 2024 SparkDI Contributors. All rights reserved.
//
import Foundation
import Synchronization

protocol Injectable {
    func resolveDependencies() throws
}

public enum Scope: Sendable {

    case singleton

    case transient

}

public final class DependencyContainer: @unchecked Sendable {

    private struct Dependency {
        let factory: @Sendable ([Any]) -> Any
        let scope: Scope
        let dependencyTypes: [Any.Type]
    }

    private let dependencies = Mutex<[ObjectIdentifier: Dependency]>([:])

    private let sharedInstances = Mutex<[ObjectIdentifier: Any]>([:])

    private let dependencyGraph = Mutex<[ObjectIdentifier: Set<ObjectIdentifier>]>([:])

    private let resolvedInstances = Mutex<Set<ObjectIdentifier>>([])

    public init() {}

    public func register<T>(
        type: T.Type,
        factory: @escaping @Sendable ([Any]) -> T,
        argumentsTypes: [Any.Type] = [],
        scope: Scope = .transient
    ) throws {

        let key = ObjectIdentifier(type)

        let dependencyIds = Set(argumentsTypes.map { ObjectIdentifier($0) })

        let dependency = Dependency(
            factory: factory,
            scope: scope,
            dependencyTypes: argumentsTypes
        )

        dependencies.withLock { deps in
            deps[key] = dependency
        }

        dependencyGraph.withLock { graph in
            graph[key] = dependencyIds
        }

    }

    public func resolve<T:Sendable>(
        type: T.Type,
        arguments: Any...
    ) throws -> T {

        let key = ObjectIdentifier(type)

        let shouldResolve = resolvedInstances.withLock { resolved in
            if resolved.contains(key) {
                return false
            }

            resolved.insert(key)

            return true
        }

        if !shouldResolve {
            return try createInstance(type: type, arguments: arguments)
        }

        defer {
            _ = resolvedInstances.withLock { resolved in
                resolved.remove(key)
            }
        }

        let instance = try createInstance(type: type, arguments: arguments)

        if let injectableInstance = instance as? Injectable {
            try injectableInstance.resolveDependencies()
        }

        return instance

    }
 
    private func createInstance<T:Sendable>(
        type: T.Type,
        arguments: Any...
    ) throws -> T {

        let key = ObjectIdentifier(type)

        let dependency = dependencies.withLock{ deps -> Dependency? in
            return deps[key]
        }

        guard let dependency = dependency else {
            throw DependencyError.dependencyNotFound(type: type)
        }

        try detectCircularDependencies(for: type)

        switch dependency.scope {

        case .singleton:

            let existingInstance = sharedInstances.withLock { instances -> T? in
                return instances[key] as? T
            }

            if let existingInstance = existingInstance {
                return existingInstance
            }

            guard let newInstance = dependency.factory(arguments) as? T else {
                throw DependencyError.resolutionFailed(type: type)
            }

            return sharedInstances.withLock { instances -> T in
                if let sharedInstance = instances[key] as? T {
                    return sharedInstance
                }

                instances[key] = newInstance
                return newInstance
            }

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

            let dependenciesIds = dependencyGraph.withLock { graph in
                graph[currentId]
            }

            if let dependenciesId = dependenciesIds {
                for dependencyId in dependenciesId {
                    let dependencyTypes = dependencies.withLock{ deps in
                        return deps[dependencyId]?.dependencyTypes
                    }

                    if let dependencyTypes = dependencyTypes {
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
