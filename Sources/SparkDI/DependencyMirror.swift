//
//  Copyright © 2025 SparkDI Contributors. All rights reserved.
//

import Foundation

struct DependencyMirror {
    let argumentTypes: [Any.Type]
    
    init(reflecting factory: Any) {
       let typeString = String(describing: factory)

        self.argumentTypes = Self.parseArgumentsTypes(from: typeString)
    }

    private static func parseArgumentsTypes(from typeString: String) -> [Any.Type] {
        guard let argsStart = typeString.firstIndex(of: "("),
              let argsEnd = typeString.firstIndex(of: ")")
        else {
            return []
        }
        
        let argsString = String(typeString[argsStart..<argsEnd])
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: "[Any]", with: "")

        return argsString
            .split(separator: ",")
            .compactMap { TypeRegistry.shared.type(from: String($0).trimmingCharacters(in: .whitespaces))}
    }
}

