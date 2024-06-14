import Cocoa
import XCTest

final class mac_voice_whispersTestsUI: XCTestCase {

  override func setUpWithError() throws {
    continueAfterFailure = false
    let app = XCUIApplication()
    app.launch()

    if let bundleIdentifier = Bundle.main.bundleIdentifier {
      UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
    }
  }

  override func tearDownWithError() throws {
    if let bundleIdentifier = Bundle.main.bundleIdentifier {
      UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
    }
  }

  func testUserFlow() throws {
    let app = XCUIApplication()
    app.activate()

    let controlOptionFlags: CGEventFlags = [.maskControl, .maskAlternate]
    let rKey: CGKeyCode = 0x0F

    var keyDown = CGEvent(keyboardEventSource: nil, virtualKey: rKey, keyDown: true)
    keyDown?.flags = controlOptionFlags
    keyDown?.post(tap: .cghidEventTap)

    var keyUp = CGEvent(keyboardEventSource: nil, virtualKey: rKey, keyDown: false)
    keyUp?.flags = controlOptionFlags
    keyUp?.post(tap: .cghidEventTap)

    sleep(2)

    let redProgressLoader = app.otherElements["redProgressLoader"]
    XCTAssertTrue(
      redProgressLoader.waitForExistence(timeout: 5),
      "Red progress loader should be visible when recording starts.")

    // Simulate Control + Option + R key press to stop recording
    keyDown = CGEvent(keyboardEventSource: nil, virtualKey: rKey, keyDown: true)
    keyDown?.flags = controlOptionFlags
    keyDown?.post(tap: .cghidEventTap)

    keyUp = CGEvent(keyboardEventSource: nil, virtualKey: rKey, keyDown: false)
    keyUp?.flags = controlOptionFlags
    keyUp?.post(tap: .cghidEventTap)

    sleep(2)

    let yellowProgressLoader = app.otherElements["yellowProgressLoader"]
    XCTAssertTrue(
      yellowProgressLoader.waitForExistence(timeout: 5),
      "Yellow progress loader should be visible when transcription starts.")

  }
}
