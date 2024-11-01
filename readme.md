# SparkDI

SparkDI is a dependency injection framework in Swift, designed for speed and performance, inspired by industry best practices. It aims to provide a simple and efficient dependency injection solution for Swift projects, with support for scopes and flexible dependency resolution.

## Features
- Constructor, property, and method dependency injection
- Scope management (Singleton, Transient)
- Easy and flexible configuration

## Installation
Add SparkDI via Swift Package Manager:
```swift
dependencies: [
    .package(url: "https://github.com/your-username/SparkDI.git", from: "0.1.0")
]
```
##  Basic Usage

###  Step 1: Create a DependencyContainer

The DependencyContainer is the core of SparkDI, where you register and resolve dependencies
```swift

let container = DependencyContainer()

```
### Step 2: Register a Dependency

To register a dependency, use the register method. You can specify the type, a factory closure to create the instance, and an optional scope (.singleton or .transient).
```swift

// Registering a singleton instance
container.register(type: String.self, instance: { "Singleton Instance" }, scope: .singleton)

// Registering a transient instance
container.register(type: Int.self, instance: { 42 }, scope: .transient)

```
    •    .singleton scope creates the instance once and reuses it for every resolution.
    •    .transient scope creates a new instance each time the dependency is resolved.
    
###Step 3: Resolve a Dependency

To get an instance of a dependency, use the resolve method:

```swift

// Resolving the singleton instance
let singletonString: String? = container.resolve(type: String.self)
print(singletonString) // Output: Singleton Instance

// Resolving the transient instance
let transientInt: Int? = container.resolve(type: Int.self)
print(transientInt) // Output: 42

```
## Future Improvements

    •    Support for multiple parameters in the register and resolve methods
    •    Additional scope options for more flexible dependency management
    •    Expanded type safety and error handling

License

MIT License
