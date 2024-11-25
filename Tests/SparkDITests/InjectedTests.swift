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

        var newInt: Injected<Int> = Injected<Int>(assembler)
        
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

        var newInt: Injected<Int> = Injected<Int>(assembler)
        
        await newInt.resolve()
        
        XCTAssertEqual(newInt.wrappedValue, 1)
    }
}
