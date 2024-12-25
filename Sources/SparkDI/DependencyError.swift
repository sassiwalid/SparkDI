//
//  Copyright © 2024 SparkDI Contributors. All rights reserved.
//

enum DependencyError: Error, Equatable {

    case unresolvedDependency(type: String)

}
