import SwiftUI
import Combine

@MainActor
final class MoviesViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var query: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String? = nil   // <-- renamed

    private let api = APIClient()
    private var page = 1
    private let pageSize = 20
    private var canLoadMore = true

    func loadInitial() async {
        page = 1
        canLoadMore = true
        movies.removeAll()
        await loadMore()
    }

    func loadMore() async {
        guard !isLoading, canLoadMore else { return }
        isLoading = true; defer { isLoading = false }
        do {
            let batch = try await api.fetchMovies(query: query, page: page, pageSize: pageSize)
            movies.append(contentsOf: batch)
            canLoadMore = !batch.isEmpty
            if canLoadMore { page += 1 }
            errorMessage = nil
        } catch {
            errorMessage = (error as NSError).localizedDescription
        }
    }

    func submitSearch() async { await loadInitial() }
}
