import Cocoa
import SwiftUI

class RecordingIndicatorWindowController: NSWindowController {
  private let hostingController: NSHostingController<RecordingIndicator>

  init() {
    let view = RecordingIndicator(isLoading: false)
    hostingController = NSHostingController(rootView: view)

    let window = NSWindow(contentViewController: hostingController)
    window.styleMask = [.borderless]
    window.isOpaque = false
    window.backgroundColor = .clear
    window.level = .screenSaver
    window.setFrame(NSRect(x: 0, y: 0, width: 30, height: 30), display: true)

    super.init(window: window)
    window.isReleasedWhenClosed = false
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func show() {
    if let screen = NSScreen.main {
      let screenFrame = screen.visibleFrame
      let windowSize = window?.frame.size ?? CGSize(width: 30, height: 30)
      let centerPoint = CGPoint(
        x: screenFrame.midX - windowSize.width / 2,
        y: screenFrame.midY - windowSize.height / 2
      )
      window?.setFrameOrigin(centerPoint)
    }
    window?.makeKeyAndOrderFront(nil)
  }

  func hide() {
    window?.orderOut(nil)
  }

  func update(isLoading: Bool) {
    hostingController.rootView = RecordingIndicator(isLoading: isLoading)
    window?.makeKeyAndOrderFront(nil)
  }
}
