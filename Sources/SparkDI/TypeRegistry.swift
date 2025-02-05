//
//  Copyright © 2025 SparkDI Contributors. All rights reserved.
//

import Foundation

actor TypeRegistry {

    static nonisolated let shared = TypeRegistry()

    private static var safeTypeMap: [String: Any.Type] = [
        "Int": Int.self,
        "String": String.self,
        "Double": Double.self,
        "Bool": Bool.self,
        "Date": Date.self,
        "Float": Float.self
    ]
    
    private var typeMap: [String: Any.Type] = safeTypeMap

    func register(type: Any.Type) {
        let typeName = String(describing: type)

        typeMap[typeName] = type
    }
    
    nonisolated func type(from name: String) -> Any.Type? {
        Self.safeTypeMap[name]
    }
}
