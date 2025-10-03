import Foundation

enum APIError: LocalizedError {
    case badStatus(Int)
    var errorDescription: String? {
        switch self {
        case .badStatus(let code): return "Server returned status \(code)"
        }
    }
}

final class APIClient {
    func fetchMovies(query: String? = nil, page: Int? = nil, pageSize: Int? = nil) async throws -> [Movie] {
        var url = API.baseURL.appendingPathComponent("movies")
        var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        var items: [URLQueryItem] = []
        if let q = query, !q.isEmpty { items.append(.init(name: "q", value: q)) }
        if let page { items.append(.init(name: "page", value: String(page))) }
        if let pageSize { items.append(.init(name: "pageSize", value: String(pageSize))) }
        if !items.isEmpty { comps.queryItems = items }
        url = comps.url!

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw APIError.badStatus((response as? HTTPURLResponse)?.statusCode ?? -1)
        }

        // Support both shapes: 1) array of movies OR 2) { items: [...] }
        let dec = JSONDecoder()
        if let page = try? dec.decode(PageEnvelope.self, from: data) {
            return page.items
        } else {
            return try dec.decode([Movie].self, from: data)
        }
    }
}

private struct PageEnvelope: Decodable {
    let items: [Movie]
    let page: Int?
    let pageSize: Int?
    let total: Int?
}
