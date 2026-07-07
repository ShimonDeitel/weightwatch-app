import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var entries: [Entry] = []
    @Published var settings: AppSettings = AppSettings()
    @Published var isPro: Bool = false

    /// Free tier allows this many total weigh-in entries before the paywall appears.
    /// Kept comfortably above seed data count so a fresh install never hits the wall immediately.
    static let freeLimit = 12

    private let entriesURL: URL
    private let settingsURL: URL

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: support, withIntermediateDirectories: true)
        entriesURL = support.appendingPathComponent("weightwatch_entries.json")
        settingsURL = support.appendingPathComponent("weightwatch_settings.json")
        load()
        if entries.isEmpty {
            seed()
        }
    }

    private func seed() {
        let now = Date()
        entries = [
            Entry(date: Calendar.current.date(byAdding: .day, value: -2, to: now) ?? now, severity: 4, note: "", note: "First logged entry"),
            Entry(date: Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now, severity: 6, note: "", note: "")
        ]
        save()
    }

    var canAddMore: Bool {
        isPro || entries.count < Store.freeLimit
    }

    func add(_ entry: Entry) {
        entries.insert(entry, at: 0)
        save()
    }

    func update(_ entry: Entry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: Entry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: entriesURL),
           let decoded = try? JSONDecoder().decode([Entry].self, from: data) {
            entries = decoded
        }
        if let data = try? Data(contentsOf: settingsURL),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = decoded
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(entries) {
            try? data.write(to: entriesURL)
        }
        if let data = try? JSONEncoder().encode(settings) {
            try? data.write(to: settingsURL)
        }
    }
}
