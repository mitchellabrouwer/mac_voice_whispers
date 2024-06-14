import HotKey
import SwiftUI

@main
struct WhisperCppApp: App {
  @StateObject private var whisperState: WhisperState
  @StateObject private var keyboardShortcutManager: KeyboardShortcutManager
  @State private var recordingIndicatorWindowController = RecordingIndicatorWindowController()

  init() {
    let whisper = WhisperState(isLoaded: false)
    let keyboardManager = KeyboardShortcutManager(whisperState: whisper)

    _whisperState = StateObject(wrappedValue: whisper)
    _keyboardShortcutManager = StateObject(wrappedValue: keyboardManager)
  }

  var body: some Scene {
    MenuBarExtra("UtilityApp", systemImage: whisperState.isRecording ? "mic" : "mic.slash") {
      AppMenu().environmentObject(whisperState).environmentObject(keyboardShortcutManager)
    }.menuBarExtraStyle(.window)

    WindowGroup {}.onChange(of: whisperState.isRecording, initial: true) {
      print("is recording changedto ", whisperState.isRecording)
      if whisperState.isRecording && !whisperState.isLoading {
        recordingIndicatorWindowController.show()
      } else {
        recordingIndicatorWindowController.hide()
      }
    }
    .onChange(of: whisperState.isLoading) {
      print("is loading changedto ", whisperState.isRecording)
      recordingIndicatorWindowController.update(isLoading: whisperState.isLoading)
      if whisperState.isLoading && !whisperState.isRecording {
        recordingIndicatorWindowController.show()
      } else {
        recordingIndicatorWindowController.hide()
      }
    }

  }
}
