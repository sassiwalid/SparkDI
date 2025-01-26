import Foundation

@propertyWrapper
struct Dependency<T> {

    var instance: T?

    let assembler: Assembler

    mutating func resolve() async throws  {
        instance = try await assembler.container.resolve(type: T.self)
    }

    var wrappedValue: T {

        guard let instance = instance else {
             fatalError("dependency must be resolved asynchronously using resolve")
        }

        return instance
    }

    init(_ assembler: Assembler) {

        self.assembler = assembler

    }

    func getOrThrow() throws -> T {
        guard let instance = instance else {
            throw DependencyError.unresolvedDependency(type: String(describing: T.self))
            
        }

        return instance
    }

}

