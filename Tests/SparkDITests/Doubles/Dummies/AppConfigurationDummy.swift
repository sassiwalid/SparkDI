//
//  Copyright © 2024 SparkDI Contributors. All rights reserved.
//
import Foundation

struct AppConfigurationDummy: Equatable {
    let version: String
    
    static func ==(lhs: AppConfigurationDummy, rhs: AppConfigurationDummy) -> Bool {
        lhs.version == rhs.version
    }
}
