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
            instance: { "Singleton instance"
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
            instance: { UUID().uuidString
            },
            scope: .transient
        )
        
        let instance1: String? = container.resolve(type: String.self)
        let instance2: String? = container.resolve(type: String.self)
        #expect(instance1 != instance2)
    }
    
    
}
#endif
final class DependencyContainerTests: XCTestCase {
    func testSingletonScope() {
        let container = DependencyContainer()
        
        container.register(type: String.self, instance: { "Singleton Instance" }, scope: .singleton)
        
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
            instance: { UUID().uuidString
            },
            scope: .transient)
        
        // Résolution
        let instance1: String? = container.resolve(type: String.self)
        let instance2: String? = container.resolve(type: String.self)
        
        // Vérifie que les deux résolutions renvoient des instances différentes
        XCTAssertNotEqual(instance1, instance2, "Transient scope should create a new instance each time")
    }
}
