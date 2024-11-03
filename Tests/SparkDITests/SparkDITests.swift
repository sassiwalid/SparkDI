#if canImport(Testing)
import Testing
#endif
import XCTest
@testable import SparkDI

#if canImport(Testing)
struct DependencyInjectionTests {

    @Test func singletonScopeWithSingleParameter() async throws {
        /// Given
        let container = DependencyContainer()

        container.register(
            type: String.self,
            factory: { _ in "Singleton instance"
            },
            scope: .singleton
        )
        /// When
        let instance1: String? = container.resolve(type: String.self)
        let instance2: String? = container.resolve(type: String.self)
        
        /// Then
        #expect(instance1 == instance2)
    }
    
    @Test func transientScopeWithSingleParameter() async throws {
        /// Given
        let container = DependencyContainer()

        container.register(
            type: String.self,
            factory: { _ in UUID().uuidString
            },
            scope: .transient
        )

        /// When

        let instance1: String? = container.resolve(type: String.self)
        let instance2: String? = container.resolve(type: String.self)
        
        /// Then
        #expect(instance1 != instance2)

    }
    
    @Test func transientScopeWithMultipleParameters() async throws {
        /// Given
        let container = DependencyContainer()

        container.register(
            type: String.self,
            factory: { args in
                guard let name = args[0] as? String, let age = args[1] as? Int else {
                    return "Invalid arguments"
                }
                return "\(name) is \(age) years old"
            },
            scope: .transient
        )

        /// When
        
        let instance: String? = container.resolve(
            type: String.self,
            arguments: ["John", 25]
        )

        /// Then

        #expect(instance == "John is 25 years old")
    }
    
    
    
    
}
#endif

final class DependencyContainerTests: XCTestCase {

    func testSingletonScopeWithSingleParameter() {
        /// Given
        let container = DependencyContainer()

        /// When
        container.register(type: String.self, factory: { _ in  "Singleton Instance" }, scope: .singleton)

        // Then
        let instance1: String? = container.resolve(type: String.self)
        let instance2: String? = container.resolve(type: String.self)

        XCTAssertTrue(
            instance1 == instance2,
            "Singleton scope should return the same instance"
        )

    }
    
    func testTransientScopeWithSingleparameter() {
        /// Given
        let container = DependencyContainer()

        container.register(
            type: String.self,
            factory: { _ in UUID().uuidString
            },
            scope: .transient
        )
        
        /// When

        let instance1: String? = container.resolve(type: String.self)
        let instance2: String? = container.resolve(type: String.self)

        /// Then

        XCTAssertNotEqual(
            instance1,
            instance2,
            "Transient scope should create a new instance each time"
        )
    }
    
    func testTransientScopeWithMultipleParameters() {
        /// Given
        let container = DependencyContainer()

        container.register(
            type: String.self,
            factory: { args in
                guard let name = args[0] as? String, let age = args[1] as? Int else {
                    return "Invalid arguments"
                }
                return "\(name) is \(age) years old"
            },
            scope: .transient
        )

        /// When

        let instance: String? = container.resolve(
            type: String.self,
            arguments: ["John", 25]
        )

        /// Then

        XCTAssertEqual(
            instance,
            "John is 25 years old"
        )
    }
}
