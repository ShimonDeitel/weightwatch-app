import XCTest

final class WeightwatchUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAddEntryFlow() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["addEntryButton"].tap()
        let saveButton = app.buttons["saveEntryButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        saveButton.tap()
    }

    func testKeyboardDismissOnTapOutside() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["addEntryButton"].tap()
        let noteField = app.textFields["noteField"]
        XCTAssertTrue(noteField.waitForExistence(timeout: 5))
        noteField.tap()
        app.typeText("hello")
        XCTAssertTrue(app.keyboards.element.exists)
        // Tap the form section header area outside the text field to dismiss keyboard.
        app.staticTexts["Details"].tap()
        XCTAssertFalse(app.keyboards.element.exists)
    }

    func testFreeLimitTriggersPaywall() throws {
        let app = XCUIApplication()
        app.launch()
        for _ in 0..<20 {
            if app.buttons["addEntryButton"].waitForExistence(timeout: 2) {
                app.buttons["addEntryButton"].tap()
                let saveButton = app.buttons["saveEntryButton"]
                if saveButton.waitForExistence(timeout: 2) {
                    saveButton.tap()
                }
            }
        }
        XCTAssertTrue(app.buttons["unlockProButton"].waitForExistence(timeout: 5) || app.staticTexts["Weightwatch Pro"].waitForExistence(timeout: 5))
    }

    func testSettingsOpensAndCloses() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["settingsDoneButton"].waitForExistence(timeout: 5))
        app.buttons["settingsDoneButton"].tap()
    }
}
