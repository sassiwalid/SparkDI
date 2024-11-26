import Foundation

@propertyWrapper
struct Dependency<T> {

    private var instance: T?

    let assembler: Assembler
    
    mutating func resolve() async {
        instance = await assembler.container.resolve(type: T.self)
    }

    var wrappedValue: T {

        if instance == nil {
             fatalError("dependency must be resolved asynchronously using resolve")
        }

        return instance!
    }

    init(_ assembler: Assembler) {

        self.assembler = assembler

    }

}

