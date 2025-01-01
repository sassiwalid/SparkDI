//
//  Copyright © 2025 SparkDI Contributors. All rights reserved.
//

import Foundation

struct TypeRegistry {

    static var shared = TypeRegistry()

    private var typeMap: [String: Any.Type] = [
        "Int": Int.self,
        "String": String.self,
        "Double": Double.self,
        "Bool": Bool.self,
        "Date": Date.self,
        "Float": Float.self
    ]

    mutating func register(type: Any.Type) {
        let typeName = String(describing: type)

        typeMap[typeName] = type
    }
    
    func type(from name: String) -> Any.Type? {
        typeMap[name]
    }
}
