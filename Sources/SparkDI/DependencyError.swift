//
//  Copyright © 2024 SparkDI Contributors. All rights reserved.
//

enum DependencyError: Error, Equatable, Sendable {

    case dependencyNotFound(type: Any.Type)

    case circularDependency

    case resolutionFailed(type: Any.Type)
    
    case unresolvedDependency(type: String)
    
    static func == (lhs: DependencyError, rhs: DependencyError) -> Bool {

        return switch (lhs, rhs) {

        case (.dependencyNotFound(let lhs), .dependencyNotFound(let rhs)):
            ObjectIdentifier(lhs) == ObjectIdentifier(rhs)

        case (.circularDependency, .circularDependency):
            true

        case (.resolutionFailed(let lhs), .resolutionFailed(let rhs)):
            ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
        
        case (.unresolvedDependency(let lhs), .unresolvedDependency(let rhs)):
            lhs == rhs
            
        default:
            false
        }
    }

}
