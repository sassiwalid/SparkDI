# SparkDI

SparkDI is a dependency injection framework in Swift, designed for speed and performance, inspired by industry best practices. It aims to provide a simple and efficient dependency injection solution for Swift projects, with support for scopes and flexible dependency resolution.

## Features
- Constructor, property, and method dependency injection
- Scope management (Singleton, Transient)
- Easy and flexible configuration
- Modular dependency registration using an `Assembler` with multiple modules
- Support for resolving dependencies with multiple arguments

## Installation
Add SparkDI via Swift Package Manager:
```swift
dependencies: [
    .package(url: "https://github.com/sassiwalid/SparkDI.git", from: "0.1.0")
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
    
### Step 3: Resolve a Dependency

To get an instance of a dependency, use the resolve method:

```swift

// Resolving the singleton instance
let singletonString: String? = container.resolve(type: String.self)
print(singletonString) // Output: Singleton Instance

// Resolving the transient instance
let transientInt: Int? = container.resolve(type: Int.self)
print(transientInt) // Output: 42

```
## Using Multiple Arguments in Dependency Resolution

SparkDI supports resolving dependencies that require multiple arguments by allowing resolve to accept a variable number of arguments.

### Step 1: Register a Dependency with Arguments

You can register a dependency that requires multiple arguments by using a factory closure that takes an array of Any types. This array will be used to pass in the required arguments when resolving the dependency.

```swift

container.register(
   type: String.self,
   factory: { args in

   guard let name = args[0] as? String, let age = args[1] as? Int else {
    return "Invalid arguments"
   }

   return "\(name) is \(age) years old"

   },
   scope: .transient
)

```
### Step 2: Resolve the Dependency with Arguments

When resolving a dependency that requires arguments, pass the arguments in the resolve method as a variadic list.

```swift

let instance: String? = container.resolve(
    type: String.self,
    arguments: ["Mohamed", 40]
)

```
This functionality allows for flexible dependency resolution, supporting dependencies that require parameters at runtime.

## Using the Assembler for Modular Dependency Management

For larger projects, you can organize dependencies into modules using the Assembler. Each module registers a group of dependencies, and the assembler applies these modules to a single DependencyContainer.

### Step 1: Define Modules

Define each module as a struct conforming to the Module protocol, which provides a method to register dependencies in the container.

```swift

struct NetworkModule: Module {

 func registerDependencies(in container: DependencyContainer) {

    container.register(
    type: APIService.self,
    instance: { APIService() },
    scope: .singleton
    )

    container.register(
    type: NetworkManager.self,
    instance: { NetworkManager() },
    scope: .transient
    )

  }

}

struct UserModule: Module {
  func registerDependencies(in container: DependencyContainer) {
    
    container.register(
        type: UserService.self,
        instance: { UserService() },
        scope: .singleton
    )

    container.register(
        type: UserSession.self,
        instance: { UserSession() }, 
        scope: .transient
    )
    
  }

}

```

### Step 2: Use the Assembler to Apply Modules

Create an Assembler and apply the modules to register dependencies.
```swift
let assembler = Assembler()

assembler.apply(modules: [NetworkModule(), UserModule()])

// Resolving dependencies
let apiService: APIService? = assembler.resolve(type: APIService.self)

let userService: UserService? = assembler.resolve(type: UserService.self)

```

## Thread-Safety with Mutex

To ensure SparkDI is thread-safe, we added a mutex (NSLock) to manage concurrent access to the dependency container. This guarantees that simultaneous reads and writes to the container do not cause race conditions or crashes.

### Why Use a Mutex?

    •    Data Integrity: Ensures the container remains in a consistent state, even under heavy concurrent access.
    •    Ease of Use: Using defer ensures the lock is always released, reducing the chance of deadlocks.

## Future Improvements

    •    Additional scope options for more flexible dependency management

License

MIT License
