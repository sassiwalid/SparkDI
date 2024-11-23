//  
//  Copyright © 2024 SparkDI Contributors. All rights reserved.
//

#if canImport(Testing)
import Testing
#endif
import XCTest
@testable import SparkDI

#if canImport(Testing)
struct AssemblerTests {
    @Test func assemblerWithMultipleModules() async {
        /// GIVEN
        let container = DependencyContainer()
        let assembler = Assembler(container: container)
        await assembler.apply(
            modules: [NetworkModule(), UserModule()]
        )

        /// WHEN

        // resolve Network module dependencies (singletons case)
        let apiService1 = await container.resolve(type: APIServiceDummy.self)
        let apiService2 = await container.resolve(type: APIServiceDummy.self)
        
        let networkManager1 = await container.resolve(type: NetworkManagerDummy.self)
        let networkManager2 = await container.resolve(type: NetworkManagerDummy.self)
        
        // resolve user module dependencies (new instance case)
        
        let userService1 = await container.resolve(type: UserServiceDummy.self)
        let userService2 = await container.resolve(type: UserServiceDummy.self)

        /// THEN

        #expect(apiService1 === apiService2)
        #expect(networkManager1 === networkManager2)
        #expect(userService1 !== userService2)
    }
}
#endif

final class AssemblerXCTests: XCTestCase {
    
    func testAssemblerWithMultipleModules() async {
        let container = DependencyContainer()
        let assembler = Assembler(container: container)
        await assembler.apply(
            modules: [NetworkModule(), UserModule()]
        )
        
        // resolve Network module dependencies (singletons case)
        let apiService1 = await container.resolve(type: APIServiceDummy.self)
        let apiService2 = await container.resolve(type: APIServiceDummy.self)
        
        let networkManager1 = await container.resolve(type: NetworkManagerDummy.self)
        let networkManager2 = await container.resolve(type: NetworkManagerDummy.self)
        
        // resolve user module dependencies (new instance case)
        
        let userService1 = await container.resolve(type: UserServiceDummy.self)
        let userService2 = await container.resolve(type: UserServiceDummy.self)
        
        XCTAssertTrue(apiService1 === apiService2)
        XCTAssertTrue(networkManager1 === networkManager2)
        XCTAssertTrue(userService1 !== userService2)
        
    }
}
