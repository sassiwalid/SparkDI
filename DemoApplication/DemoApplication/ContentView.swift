//  
//  Copyright © 2024 SparkDI Contributors. All rights reserved.
//


import SwiftUI
import SparkDI

struct DemoAppDependencies {
    static let container: DependencyContainer = {
        let container = DependencyContainer()
        container.register(type: String.self) { _ in
            return "hello SparkDI"
        }
        return container
    }()
}

struct ContentView: View {
    var body: some View {
        let message: String = DemoAppDependencies.container.resolve(type: String.self)!
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(message)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
