enum Scope {
    case singleton
    case transient
}

final class DependencyContainer {
    private var dependencies: [ObjectIdentifier: () -> Any] = [:]

    private var sharedInstances: [ObjectIdentifier: Any] = [:]
    
    func register<T>(type: T.Type, instance: @escaping ()-> T, scope: Scope = .transient) {
        let key = ObjectIdentifier(type)
        
        if scope == .singleton {
            sharedInstances[key] = instance()
        } else {
            dependencies[key] = instance
        }
    }
    
    func resolve<T>(type: T.Type) -> T? {
        let key = ObjectIdentifier(type)
        
        if let sharedInstance = sharedInstances[key] {
            return sharedInstance as? T
        }
        
        if let dependency = dependencies[key] {
            return dependency() as? T
        }
        
        return nil
        
    }
}
