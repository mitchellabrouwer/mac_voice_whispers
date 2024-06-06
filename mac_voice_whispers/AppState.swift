import HotKey
import SwiftUI

@MainActor
class AppState: ObservableObject {
  static let shared = AppState()
  @Published var whisperState = WhisperState()
  let hotkey: HotKey

  private init() {
    hotkey = HotKey(key: .i, modifiers: [.command, .control, .option])

    hotkey.keyDownHandler = {
      Task {
        await self.whisperState.toggleRecord()
      }
    }
  }

}
