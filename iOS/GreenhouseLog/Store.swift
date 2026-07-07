import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    static let freeLimit = 10

    @Published var items: [Reading] = []
    @Published var isPro: Bool = false

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("greenhouselog_items.json")
        load()
    }

    var canAddMore: Bool {
        isPro || items.count < Store.freeLimit
    }

    func add(_ item: Reading) {
        items.insert(item, at: 0)
        save()
    }

    func update(_ item: Reading) {
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            items[idx] = item
            save()
        }
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: Reading) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([Reading].self, from: data) else {
            items = Store.seedData()
            save()
            return
        }
        items = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    static func seedData() -> [Reading] {
        [
        Reading(date: Date().addingTimeInterval(-86400), location: "Bench 1", tempF: "72", humidity: "55"),
        Reading(date: Date().addingTimeInterval(-172800), location: "Propagation Zone", tempF: "78", humidity: "70"),
        Reading(date: Date().addingTimeInterval(-259200), location: "Back Wall", tempF: "65", humidity: "45")
        ]
    }
}
