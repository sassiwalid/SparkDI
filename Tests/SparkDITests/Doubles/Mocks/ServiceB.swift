//
//  Copyright © 2025 SparkDI Contributors. All rights reserved.
//

@testable import SparkDI

final class ServiceB: Sendable {
    let serviceA: ServiceA

    init(serviceA: ServiceA) {
        self.serviceA = serviceA
    }
}
