
import Testing

@testable import SparkDI

struct SparkDIInjectedTests {
    @Test func wrappedValueReturnResolvedInstance() throws {
        let container = DependencyContainer()
        let assembler = Assembler(container: container)
        
        try container.register(type: Int.self) { _ in 1 }

        var newInt: Dependency<Int> = Dependency<Int>(assembler)
        
        try newInt.resolve()
        
        #expect(newInt.wrappedValue == 1)
    }
    
    @Test func unresolvedDependencyShouldThrowsErrorWhenCallGetOrThrow() {

        let container = DependencyContainer()

        let assembler = Assembler(container: container)

        var newInt: Dependency<Int> = Dependency<Int>(assembler)

        newInt.resolve(with: 2)

        let instance = try? newInt.getOrThrow()

        #expect(instance == 2)
    }
    
    @Test func resolvedDependencyShouldNotThrowsErrorWhenCallGetOrThrow() {
        let container = DependencyContainer()

        let assembler = Assembler(container: container)

        let newInt = Dependency<Int>(assembler)

        #expect{ try newInt.getOrThrow() } throws: { error in
            (error as? DependencyError) == .unresolvedDependency(type: "Int")
        }
        
    }
    
    
}

extension Dependency {

    mutating func resolve(with mockInstance: T) {
        instance = mockInstance
    }

}

enum FatalErrorUtil {

    nonisolated(unsafe) static var fatalErrorClosure: ((String, StaticString, UInt) -> Void)?

    static func replaceFatalError(_ closure: @escaping (String, StaticString, UInt) -> Void) {

        fatalErrorClosure = closure
    }

    static func restoreFatalError() {

        fatalErrorClosure = nil
    }

    static func testFatalError(
        _ message: @autoclosure () -> String = String(),
        file: StaticString = #file,
        line: UInt = #line
    ) {

        if let closure = FatalErrorUtil.fatalErrorClosure {
            closure(message(), file, line)
            while true {}
        } else {

            Swift.fatalError(message(), file: file, line: line)
        }

    }

}

#if TEST
func fatalError(
    _ message: @autoclosure () -> String,
    file: StaticString = #file,
    line: UInt = #line
) -> Never {
    FatalErrorUtil.testFatalError(message(), file: file, line: line)
}
#endif


