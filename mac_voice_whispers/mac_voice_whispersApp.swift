import HotKey
import SwiftUI

@main
struct WhisperCppApp: App {
    @StateObject private var whisperState: WhisperState
    @StateObject private var keyboardShortcutManager: KeyboardShortcutManager

    init() {
        let whisperState = WhisperState()
        _whisperState = StateObject(wrappedValue: whisperState)
        
        _keyboardShortcutManager = StateObject(wrappedValue: KeyboardShortcutManager(whisperState: whisperState))
    }

  var body: some Scene {
    MenuBarExtra("UtilityApp", systemImage: whisperState.isRecording ? "mic" : "hammer") {
      AppMenu().environmentObject(whisperState)
    }.menuBarExtraStyle(.window)

    WindowGroup {}

  }

}

