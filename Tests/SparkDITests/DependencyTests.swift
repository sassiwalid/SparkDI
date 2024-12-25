#if canImport(Testing)
import Testing
#endif
import XCTest
@testable import SparkDI

#if canImport(Testing)
struct SparkDIInjectedTests {
    @Test func wrappedValueReturnResolvedInstance() async {
        let container = DependencyContainer()
        let assembler = Assembler(container: container)
        
        await container.register(type: Int.self) { _ in 1 }

        var newInt: Dependency<Int> = Dependency<Int>(assembler)
        
        await newInt.resolve()
        
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
#endif

final class InjectedTests: XCTestCase {

    func testwrappedValueReturnResolvedInstance() async {

        let container = DependencyContainer()

        let assembler = Assembler(container: container)

        await container.register(type: Int.self) { _ in 1 }

        var newInt: Dependency<Int> = Dependency<Int>(assembler)

        await newInt.resolve()

        XCTAssertEqual(newInt.wrappedValue, 1)
    }

    func testAssertWithoutRegisterOnContainerShouldThrowsFatalError() {

        let container = DependencyContainer()

        let assembler = Assembler(container: container)

        let newString = Dependency<String>(assembler)

        XCTAssertThrowsFatalError {
            _ = newString.wrappedValue
        }

    }
    
    func testUnresolvedDependencyShouldThrowsErrorWhenCallGetOrThrow() async {
        let container = DependencyContainer()

        let assembler = Assembler(container: container)

        var newInt: Dependency<Int> = Dependency<Int>(assembler)
        
        newInt.resolve(with: 2)

        let instance = try? newInt.getOrThrow()
        
        XCTAssertEqual(instance, 2)
        
    }
    
    func testResolvedDependencyShouldNotThrowsErrorWhenCallGetOrThrow() {
        let container = DependencyContainer()

        let assembler = Assembler(container: container)

        let newInt = Dependency<Int>(assembler)
        
        XCTAssertThrowsError(try newInt.getOrThrow()) { error in
            XCTAssertEqual(error as? DependencyError, .unresolvedDependency(type: "Int"))
        }
        
    }
}

extension Dependency {

    mutating func resolve(with mockInstance: T) {
        instance = mockInstance
    }

}

extension XCTestCase {

    func XCTAssertThrowsFatalError(_ expression: @escaping () -> Void, file: StaticString = #file, line: UInt = #line) {

        let expectation = self.expectation(description: "Fatal error")

        FatalErrorUtil.replaceFatalError { _,_,_ in
            expectation.fulfill()
        }

        DispatchQueue.global(qos: .userInitiated).async {
            FatalErrorUtil.testFatalError("dependency must be resolved asynchronously using resolve")
        }

        wait(for: [expectation], timeout: 1.0)

        FatalErrorUtil.restoreFatalError()

    }
}

enum FatalErrorUtil {

    static var fatalErrorClosure: ((String, StaticString, UInt) -> Void)?

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


