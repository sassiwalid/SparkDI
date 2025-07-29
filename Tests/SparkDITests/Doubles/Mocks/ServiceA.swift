//
//  Copyright © 2025 SparkDI Contributors. All rights reserved.
//

@testable import SparkDI

final class ServiceA: Sendable {
    let serviceB: ServiceB

    init(serviceB: ServiceB) {
        self.serviceB = serviceB
    }
}
