//  
//  Copyright © 2024 SparkDI Contributors. All rights reserved.
//

#if canImport(Testing)
import Testing
#endif
import XCTest
@testable import SparkDI

#if canImport(Testing)
struct DependencyInjectionTests {
    
    @Test func singletonScopeWithoutParameter() async throws {
        /// Given
        let container = DependencyContainer()

        await container.register(
            type: String.self,
            factory: { _ in
                "Singleton instance"
            },
            scope: .singleton
        )
        /// When
        let instance1: String? = await container.resolve(type: String.self)
        let instance2: String? = await container.resolve(type: String.self)
        
        /// Then
        #expect(instance1 == instance2)
    }
    
    @Test func transientScopeWithoutParameter() async throws {
        /// Given
        let container = DependencyContainer()

        await container.register(
            type: String.self,
            factory: { _ in
                UUID().uuidString
            },
            scope: .transient
        )

        /// When

        let instance1: String? = await container.resolve(type: String.self)
        let instance2: String? = await container.resolve(type: String.self)
        
        /// Then
        #expect(instance1 != instance2)

    }
    
    @Test func singletonScopeWithSingleParameter() async throws {
        /// Given
        let container = DependencyContainer()

        await container.register(
            type: AppConfigurationDummy.self,
            factory: { args in
                guard let version = args.first as? String else { fatalError("Invalid arguments") }
                
                return AppConfigurationDummy(version: version)
            },
            scope: .singleton
        )

        /// When

        let instance1: AppConfigurationDummy? = await container.resolve(
            type: AppConfigurationDummy.self,
            arguments: "1.0.0"
        )
        
        let instance2: AppConfigurationDummy? = await container.resolve(type: AppConfigurationDummy.self)
        
        /// Then
        #expect(instance1 == instance2)

    }
    
    @Test func transientScopeWithSingleParameter() async throws {
        /// Given
        let container = DependencyContainer()

        await container.register(
            type: AppConfigurationDummy.self,
            factory: { args in
                guard let version = args.first as? String else { fatalError("Invalid arguments") }
                
                return AppConfigurationDummy(version: version)
            },
            scope: .transient
        )

        /// When

        let instance1: AppConfigurationDummy? = await container.resolve(
            type: AppConfigurationDummy.self,
            arguments: "1.0.0"
        )
        
        let instance2: AppConfigurationDummy? = await container.resolve(
            type: AppConfigurationDummy.self,
            arguments: "2.0.0"
        )
        
        /// Then
        #expect(instance1 != instance2)

    }
    
    @Test func transientScopeWithMultipleParameters() async throws {
        /// Given
        let container = DependencyContainer()

        await container.register(
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
        
        let instance: String? = await container.resolve(
            type: String.self,
            arguments: ["John", 25]
        )

        /// Then

        #expect(instance == "John is 25 years old")
    }

}
#endif

final class DependencyContainerTests: XCTestCase {

    func testSingletonScopeWithoutParameter() async {
        /// Given
        let container = DependencyContainer()

        /// When
        await container.register(type: String.self, factory: { _ in  "Singleton Instance" }, scope: .singleton)

        // Then
        let instance1: String? = await container.resolve(type: String.self)
        let instance2: String? = await container.resolve(type: String.self)

        XCTAssertTrue(
            instance1 == instance2,
            "Singleton scope should return the same instance"
        )

    }
    
    func testTransientScopeWithoutParameter() async {
        /// Given
        let container = DependencyContainer()

        await container.register(
            type: String.self,
            factory: { _ in UUID().uuidString
            },
            scope: .transient
        )
        
        /// When

        let instance1: String? = await container.resolve(type: String.self)
        let instance2: String? = await container.resolve(type: String.self)

        /// Then

        XCTAssertNotEqual(
            instance1,
            instance2,
            "Transient scope should create a new instance each time"
        )
    }
    
    func testSingletonScopeWithSingleParameter() async {
        
        /// Given
        let container = DependencyContainer()

        await container.register(
            type: AppConfigurationDummy.self,
            factory: { args in
                guard let version = args.first as? String else { fatalError("Invalid arguments") }
                
                return AppConfigurationDummy(version: version)
            },
            scope: .singleton
        )

        /// When

        let instance1: AppConfigurationDummy? = await container.resolve(
            type: AppConfigurationDummy.self,
            arguments: "1.0.0"
        )
        
        let instance2: AppConfigurationDummy? = await container.resolve(type: AppConfigurationDummy.self)
        
        /// Then
        XCTAssertTrue(
            instance1 == instance2,
            "Singleton scope should return the same instance"
        )

    }

    func testTransientScopeWithSingleparameter() async {
        
        /// Given
        let container = DependencyContainer()

        await container.register(
            type: AppConfigurationDummy.self,
            factory: { args in
                guard let version = args.first as? String else { fatalError("Invalid arguments") }
                
                return AppConfigurationDummy(version: version)
            },
            scope: .transient
        )

        /// When

        let instance1: AppConfigurationDummy? = await container.resolve(
            type: AppConfigurationDummy.self,
            arguments: "1.0.0"
        )
        
        let instance2: AppConfigurationDummy? = await container.resolve(
            type: AppConfigurationDummy.self,
            arguments: "2.0.0"
        )
        
        /// Then
        
        XCTAssertNotEqual(
            instance1,
            instance2,
            "Transient scope should create a new instance each time"
        )
    }
    
    
    func testTransientScopeWithMultipleParameters() async {
        /// Given
        let container = DependencyContainer()

        await container.register(
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

        let instance: String? = await container.resolve(
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
