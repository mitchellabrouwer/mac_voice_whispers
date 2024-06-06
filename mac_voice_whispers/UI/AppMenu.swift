import AVFoundation
import SwiftUI

struct AppMenu: View {
  @EnvironmentObject var appState: WhisperState

  func toggleRecording() {
    Task {
      print("Before toggling, isRecording:", appState.isRecording)
      await appState.toggleRecord()
      print("After toggling, isRecording:", appState.isRecording)
    }
  }

  func quit() {
    NSApplication.shared.terminate(nil)
  }

  var body: some View {
    VStack(alignment: .leading) {
      Button(
        action: toggleRecording,
        label: { Text(appState.isRecording ? "Stop recording" : "Start recording") }
      ).padding(10).keyboardShortcut("i", modifiers: [.control, .command, .option])

      Divider()

      VStack {
        Text("Recording Status:")
        Text(appState.isRecording ? "Recording" : "Not Recording")
          .foregroundColor(appState.isRecording ? .red : .green)
      }
      .padding()

      Button(action: quit, label: { Text("Quit") }).padding(10)

      ScrollView {
        Text(verbatim: appState.logger)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
  }
}

