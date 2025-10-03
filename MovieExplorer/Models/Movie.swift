import Foundation

struct Movie: Decodable, Identifiable, Hashable {
    let id: Int
    let title: String
    let year: Int
    let rating: Double
}
