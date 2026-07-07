import XCTest
@testable import Weightwatch

@MainActor
final class WeightwatchTests: XCTestCase {
    func testFreshStoreSeedsBelowFreeLimit() {
        let store = Store()
        XCTAssertLessThan(store.entries.count, Store.freeLimit)
    }

    func testCanAddMoreWhenBelowLimit() {
        let store = Store()
        XCTAssertTrue(store.canAddMore)
    }

    func testAddEntryIncreasesCount() {
        let store = Store()
        let before = store.entries.count
        store.add(Entry(severity: 7, note: "test"))
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testDeleteEntryRemovesIt() {
        let store = Store()
        let entry = Entry(severity: 3, note: "to delete")
        store.add(entry)
        store.delete(entry)
        XCTAssertFalse(store.entries.contains(where: { $0.id == entry.id }))
    }

    func testUpdateEntryChangesSeverity() {
        let store = Store()
        var entry = Entry(severity: 2, note: "orig")
        store.add(entry)
        entry.severity = 9
        store.update(entry)
        XCTAssertEqual(store.entries.first(where: { $0.id == entry.id })?.severity, 9)
    }

    func testFreeLimitBlocksAddingWhenNotPro() {
        let store = Store()
        store.isPro = false
        for _ in 0..<(Store.freeLimit + 5) {
            store.add(Entry(severity: 1, note: "x"))
        }
        XCTAssertFalse(store.canAddMore)
    }

    func testProUserCanAlwaysAdd() {
        let store = Store()
        store.isPro = true
        for _ in 0..<(Store.freeLimit + 5) {
            store.add(Entry(severity: 1, note: "x"))
        }
        XCTAssertTrue(store.canAddMore)
    }

    func testDeleteAtOffsetsRemovesCorrectEntry() {
        let store = Store()
        store.entries = []
        let e1 = Entry(severity: 1, note: "one")
        let e2 = Entry(severity: 2, note: "two")
        store.add(e2)
        store.add(e1)
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.entries.first?.id, e2.id)
    }
}
