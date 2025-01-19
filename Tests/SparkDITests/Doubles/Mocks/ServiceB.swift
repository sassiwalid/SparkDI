//
//  Copyright © 2025 SparkDI Contributors. All rights reserved.
//

@testable import SparkDI

class ServiceB {
    let serviceA: ServiceA

    init(serviceA: ServiceA) {
        self.serviceA = serviceA
    }
}
