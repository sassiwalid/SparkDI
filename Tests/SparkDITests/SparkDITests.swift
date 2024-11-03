#if canImport(Testing)
import Testing
#endif
import XCTest
@testable import SparkDI

#if canImport(Testing)
struct DependencyInjectionTests {
    @Test func singletonScope() async throws {
        let container = DependencyContainer()

        container.register(
            type: String.self,
            factory: { _ in "Singleton instance"
            },
            scope: .singleton
        )
        
        let instance1: String? = container.resolve(type: String.self)
        let instance2: String? = container.resolve(type: String.self)
        #expect(instance1 == instance2)
    }
    
    @Test func transientScope() async throws {
        let container = DependencyContainer()

        container.register(
            type: String.self,
            factory: { _ in UUID().uuidString
            },
            scope: .transient
        )
        
        let instance1: String? = container.resolve(type: String.self)
        let instance2: String? = container.resolve(type: String.self)
        #expect(instance1 != instance2)
    }
    
    @Test func transientScopeWithMultipleParameters() async throws {
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
        
        let sharedInstance: String? = container.resolve(type: String.self, arguments: ["John", 25])
        #expect(sharedInstance == "John is 25 years old")
    }
    
    
    
    
}
#endif
final class DependencyContainerTests: XCTestCase {
    func testSingletonScope() {
        let container = DependencyContainer()
        
        container.register(type: String.self, factory: { _ in  "Singleton Instance" }, scope: .singleton)
        
        // Résolution
        let instance1: String? = container.resolve(type: String.self)
        let instance2: String? = container.resolve(type: String.self)
        
        // Vérifie que les deux résolutions renvoient la même instance
        XCTAssertTrue(instance1 == instance2, "Singleton scope should return the same instance")
    }
    
    func testTransientScope() {
        let container = DependencyContainer()
        
        // Enregistrement en transient
        container.register(
            type: String.self,
            factory: { _ in UUID().uuidString
            },
            scope: .transient)
        
        // Résolution
        let instance1: String? = container.resolve(type: String.self)
        let instance2: String? = container.resolve(type: String.self)
        
        // Vérifie que les deux résolutions renvoient des instances différentes
        XCTAssertNotEqual(instance1, instance2, "Transient scope should create a new instance each time")
    }
}
