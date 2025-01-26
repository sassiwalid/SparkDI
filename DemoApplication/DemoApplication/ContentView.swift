//  
//  Copyright © 2024 SparkDI Contributors. All rights reserved.
//


import SwiftUI
import SparkDI

struct ContentView: View {
    
    @State private var message: String = ""
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(message)
        }
        .padding()
        .task {
            do {
                try await AppAssembler.initialize()

                message = try await AppAssembler.container.resolve(type: String.self)
                
            } catch {
                message = "Error: \(error)"
            }
        }
       
    }
}

#Preview {
    ContentView()
}
