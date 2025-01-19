//
//  Copyright © 2025 SparkDI Contributors. All rights reserved.
//

@testable import SparkDI

class ServiceA {
    let serviceB: ServiceB

    init(serviceB: ServiceB) {
        self.serviceB = serviceB
    }
}
