import Foundation

struct Reading: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date = Date()
    var location: String
    var tempF: String
    var humidity: String
}
