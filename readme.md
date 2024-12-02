# SparkDI

SparkDI is a dependency injection framework in Swift, designed for speed and performance, inspired by industry best practices. It aims to provide a simple and efficient dependency injection solution for Swift projects, with support for scopes and flexible dependency resolution.

## Features

    •    Constructor, Property, and Method Dependency Injection
    •    Scope Management: Singleton and Transient
    •    Property Wrapper Support: Use @Dependency for cleaner, safer dependency injection
    •    Actor-Based Thread Safety: Modern Swift Concurrency for managing concurrent access
    •    Modular Dependency Registration: Organize and manage dependencies with an Assembler and modules
    •    Support for Dependencies with Multiple Arguments

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
await container.register(type: String.self, instance: { "Singleton Instance" }, scope: .singleton)

// Registering a transient instance
await container.register(type: Int.self, instance: { 42 }, scope: .transient)

```
    •    .singleton scope creates the instance once and reuses it for every resolution.
    •    .transient scope creates a new instance each time the dependency is resolved.
    
### Step 3: Resolve a Dependency

To get an instance of a dependency, use the resolve method:

```swift

// Resolving the singleton instance
let singletonString: String? = await container.resolve(type: String.self)
print(singletonString) // Output: Singleton Instance

// Resolving the transient instance
let transientInt: Int? = await container.resolve(type: Int.self)
print(transientInt) // Output: 42

```
## Using Multiple Arguments in Dependency Resolution

SparkDI supports resolving dependencies that require multiple arguments by allowing resolve to accept a variable number of arguments.

### Step 1: Register a Dependency with Arguments

You can register a dependency that requires multiple arguments by using a factory closure that takes an array of Any types. This array will be used to pass in the required arguments when resolving the dependency.

```swift

await container.register(
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

let instance: String? = await container.resolve(
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

    await container.register(
    type: APIService.self,
    instance: { APIService() },
    scope: .singleton
    )

    await container.register(
    type: NetworkManager.self,
    instance: { NetworkManager() },
    scope: .transient
    )

  }

}

struct UserModule: Module {
  func registerDependencies(in container: DependencyContainer) {
    
    await container.register(
        type: UserService.self,
        instance: { UserService() },
        scope: .singleton
    )

    await container.register(
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
let apiService: APIService? = await assembler.resolve(type: APIService.self)

let userService: UserService? = await assembler.resolve(type: UserService.self)

```

## Using the @Dependency Property Wrapper

The @Dependency property wrapper simplifies dependency injection in classes, structs, or views. It integrates seamlessly with the assembler.

Step 1: Define a Class with Dependencies
```swift
class ViewController {
    @Dependency(assembler) var service: SomeService

    func load() async {
        await $service.resolve() // Asynchronously resolve the dependency
        service.performAction()
    }
}

```
Step 2: Configure Dependencies
```swift
let container = DependencyContainer()
let assembler = Assembler(container: container)

Task {
    await container.register(SomeService.self) { SomeService() }

    let viewController = ViewController()
    await viewController.load() // Output: Service is performing an action!
}

```

Advantages of the @Dependency Property Wrapper and Actor-Based Thread Safety

    •    Simplified Code: The property wrapper reduces boilerplate for dependency injection.
    •    Concurrent Safety: Actors protect shared state, ensuring stability during heavy multithreading.
    •    Asynchronous Compatibility: Both @Dependency and actors work natively with Swift’s async/await.

## Actor-Based Thread Safety

SparkDI uses actors instead of NSLock or other manual synchronization mechanisms to ensure thread safety.
Why Use Actors?

    •    Automatic Synchronization: Actors serialize access to their state, ensuring thread safety without requiring manual locks.
    •    Modern Concurrency: Aligns with Swift’s concurrency model (async/await) for safer, more scalable multithreading.
    •    Performance: Actors reduce the risk of deadlocks and race conditions, improving stability under heavy concurrent access.


## Future Improvements

    •   Additional scope options for more flexible dependency management.
    •   Enhanced error handling (replace fatalError with throw for better debugging).
    •   Optimizations for larger dependency graphs.

## License

MIT License
