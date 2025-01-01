//
//  Copyright © 2025 SparkDI Contributors. All rights reserved.
//

import Foundation

struct DependencyMirror {
    let argumentTypes: [Any.Type]
    
    init(reflecting factory: Any) {
        
        let factoryType = type(of: factory)
        
        let functionType = String(describing: factoryType)
        
        guard let argsStart = functionType.firstIndex(of: "("),
              let argsEnd = functionType.firstIndex(of: ")") else {
            self.argumentTypes = []
            
            return
        }
        
        let argsString = String(functionType[argsStart..<argsEnd])
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: "[Any]", with: "")
        
        self.argumentTypes = argsString
            .split(separator: ",")
            .compactMap { arg in
                let typeName = arg.trimmingCharacters(in: .whitespaces)
                return TypeRegistry.shared.type(from: typeName)
            }
        
    }

}

