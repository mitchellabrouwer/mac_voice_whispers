import HotKey
import SwiftUI

@main
struct WhisperCppApp: App {
  @StateObject private var whisperState: WhisperState
  @StateObject private var keyboardShortcutManager: KeyboardShortcutManager

  init() {
    let whisper = WhisperState()
    let keyboardManager = KeyboardShortcutManager(whisperState: whisper)

    _whisperState = StateObject(wrappedValue: whisper)
    _keyboardShortcutManager = StateObject(wrappedValue: keyboardManager)
  }

  var body: some Scene {
    MenuBarExtra("UtilityApp", systemImage: whisperState.isRecording ? "mic" : "hammer") {
      AppMenu().environmentObject(whisperState).environmentObject(keyboardShortcutManager)

    }.menuBarExtraStyle(.window)

    WindowGroup {}

  }

}
