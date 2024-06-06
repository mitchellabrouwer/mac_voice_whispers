import AVFoundation
import SwiftUI

struct AppMenu: View {
  @ObservedObject var appState: AppState
  
  func toggleRecording() {
    Task {
      await appState.whisperState.toggleRecord()
    }
  }

  func quit() {
    NSApplication.shared.terminate(nil)
  }

  var body: some View {
    VStack(alignment: .leading) {
      Button(
        action: toggleRecording,
        label: { Text(appState.whisperState.isRecording ? "Stop recording" : "Start recording") }
      ).padding(10).keyboardShortcut("i", modifiers: [.control, .command, .option])

      Divider()
      
      Button(action: quit, label: { Text("Quit") }).padding(10)

      ScrollView {
        Text(verbatim: appState.whisperState.messageLog)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
  }
}
