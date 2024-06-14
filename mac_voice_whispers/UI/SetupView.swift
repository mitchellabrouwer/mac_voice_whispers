import SwiftUI

struct SetupView: View {
  @EnvironmentObject var whisperState: WhisperState
  @State private var recordingIndicatorWindowController = RecordingIndicatorWindowController()

  var body: some View {
    VStack {
      Text("ContentView")
      Button("Toggle Recording") {
        Task {
          print("hello")
        }
      }
    }.onChange(of: whisperState.isRecording) {
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
