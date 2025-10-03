import SwiftUI

struct ContentView: View {
    @StateObject private var vm = MoviesViewModel()

    var body: some View {
        NavigationView {
            Group {
                if let err = vm.errorMessage {
                    VStack(spacing: 10) {
                        Text("Failed to load:\n\(err)").multilineTextAlignment(.center)
                        Button("Retry") { Task { await vm.loadInitial() } }
                    }.padding()
                } else {
                    List {
                        ForEach(vm.movies) { m in
                            VStack(alignment: .leading) {
                                Text(m.title).font(.headline)
                                Text("\(m.year) • \(String(format: "%.1f", m.rating))")
                                    .font(.subheadline).foregroundStyle(.secondary)
                            }
                            .onAppear {
                                // infinite scroll: when last cell appears, load next page
                                if m.id == vm.movies.last?.id {
                                    Task { await vm.loadMore() }
                                }
                            }
                        }
                        if vm.isLoading { ProgressView("Loading…") }
                    }
                }
            }
            .navigationTitle("Movies")
            .searchable(text: $vm.query, prompt: "Search movies")
            .onSubmit(of: .search) { Task { await vm.submitSearch() } }
            .task { await vm.loadInitial() }
        }
    }
}

#Preview { ContentView() }
