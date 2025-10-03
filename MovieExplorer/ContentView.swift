import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                Text("Inception (2010)")
                Text("Interstellar (2014)")
            }
            .navigationTitle("Movies")
        }
    }
}

#Preview {
    ContentView()
}

