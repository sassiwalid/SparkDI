//  
//  Copyright © 2024 SparkDI Contributors. All rights reserved.
//
import Foundation
import Testing

@testable import SparkDI

struct DependencyInjectionTests {
    
    @Test func singletonScopeWithoutParameter() throws {
        /// Given
        let container = DependencyContainer()

        try container.register(
            type: String.self,
            factory: { _ in
                "Singleton instance"
            },
            scope: .singleton
        )
        /// When
        let instance1: String? = try container.resolve(type: String.self)
        let instance2: String? = try container.resolve(type: String.self)
        
        /// Then
        #expect(instance1 == instance2)
    }
    
    @Test func transientScopeWithoutParameter() throws {
        /// Given
        let container = DependencyContainer()

        try container.register(
            type: String.self,
            factory: { _ in
                UUID().uuidString
            },
            scope: .transient
        )

        /// When

        let instance1: String? = try container.resolve(type: String.self)
        let instance2: String? = try container.resolve(type: String.self)
        
        /// Then
        #expect(instance1 != instance2)

    }
    
    @Test func singletonScopeWithSingleParameter() throws {
        /// Given
        let container = DependencyContainer()

        try container.register(
            type: AppConfigurationDummy.self,
            factory: { args in
                guard let version = args.first as? String else { fatalError("Invalid arguments") }
                
                return AppConfigurationDummy(version: version)
            },
            scope: .singleton
        )

        /// When

        let instance1: AppConfigurationDummy? = try container.resolve(
            type: AppConfigurationDummy.self,
            arguments: "1.0.0"
        )
        
        let instance2: AppConfigurationDummy? = try container.resolve(type: AppConfigurationDummy.self)
        
        /// Then
        #expect(instance1 == instance2)

    }
    
    @Test func transientScopeWithSingleParameter() throws {
        /// Given
        let container = DependencyContainer()

        try container.register(
            type: AppConfigurationDummy.self,
            factory: { args in
                guard let version = args.first as? String else { fatalError("Invalid arguments") }
                
                return AppConfigurationDummy(version: version)
            },
            scope: .transient
        )

        /// When

        let instance1: AppConfigurationDummy? = try container.resolve(
            type: AppConfigurationDummy.self,
            arguments: "1.0.0"
        )
        
        let instance2: AppConfigurationDummy? = try container.resolve(
            type: AppConfigurationDummy.self,
            arguments: "2.0.0"
        )
        
        /// Then
        #expect(instance1 != instance2)

    }
    
    @Test func transientScopeWithMultipleParameters() throws {
        /// Given
        let container = DependencyContainer()

        try container.register(
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
        
        let instance: String? = try container.resolve(
            type: String.self,
            arguments: ["John", 25]
        )

        /// Then

        #expect(instance == "John is 25 years old")
    }

}
