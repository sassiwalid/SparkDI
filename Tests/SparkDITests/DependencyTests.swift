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

        var newString = Dependency<String>(assembler)

        XCTAssertThrowsFatalError {
            _ = newString.wrappedValue
        }

    }
}

extension XCTestCase {

    func XCTAssertThrowsFatalError(_ expression: @escaping () -> Void, file: StaticString = #file, line: UInt = #line) {

        let expectation = self.expectation(description: "Fatal error")

        FatalErrorUtil.replaceFatalError { _,_,_ in
            expectation.fulfill()
        }

        DispatchQueue.global(qos: .userInitiated).async(execute: expression)

        waitForExpectations(timeout: 0.1) { _ in
            FatalErrorUtil.restoreFatalError()
        }

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

    // Override fatalError
    func fatalError(
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) -> Never {
        if let closure = FatalErrorUtil.fatalErrorClosure {
            closure(message(), file, line)
            while true {}
        } else {

            Swift.fatalError(message(), file: file, line: line)
        }

    }

}

