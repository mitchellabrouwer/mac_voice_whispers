import HotKey
import SwiftUI

@MainActor
class KeyboardShortcutManager: ObservableObject {
    @Published var whisperState: WhisperState
    let hotkey: HotKey

    init(whisperState: WhisperState) {
        self.whisperState = whisperState
        hotkey = HotKey(key: .i, modifiers: [.command, .control, .option])
        hotkey.keyDownHandler = {
            Task {
                await self.whisperState.toggleRecord()
            }
        }
    }
}
