import Foundation

struct Entry: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date
    var severity: Int          // 0...10 scale, meaning varies per app context
    var note: String

    init(id: UUID = UUID(), date: Date = Date(), severity: Int = 5, note: String = "") {
        self.id = id
        self.date = date
        self.severity = severity
        self.note = note
    }
}

struct AppSettings: Codable, Equatable {
    var remindersEnabled: Bool = true
    var iCloudSyncEnabled: Bool = false
    var celsiusOrMetric: Bool = false
}
