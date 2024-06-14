import AVFoundation
import SwiftUI

struct AppMenu: View {
  @EnvironmentObject var whisperState: WhisperState
  @EnvironmentObject var keyboardShortcutManager: KeyboardShortcutManager

  @State private var newShortcutKey: String = "r"

  func toggleRecording() {
    Task {
      print("Before toggling, isRecording:", whisperState.isRecording)
      await whisperState.toggleRecord()
      print("After toggling, isRecording:", whisperState.isRecording)
    }
  }

  func quit() {
    NSApplication.shared.terminate(nil)
  }

  var body: some View {
    VStack(alignment: .center, spacing: 10) {
      Text("Whisper voice to text")
        .font(.title)
        .padding(.bottom, 2)
      Button(action: toggleRecording) {
        Text(whisperState.isRecording ? "Stop recording" : "Start recording")
          .padding(1)
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(whisperState.isRecording ? Color.green : Color.gray)
      .clipShape(Capsule())
      .accessibilityIdentifier("toggleRecordingButton")
      .onHover { hovering in
        if hovering {
          NSCursor.pointingHand.push()
        } else {
          NSCursor.pop()
        }
      }
      .buttonStyle(PlainButtonStyle())

      VStack {
        Text("Recording Status:")
        Text(whisperState.isRecording ? "Recording" : "Not Recording")
          .foregroundColor(whisperState.isRecording ? .red : .green)
          .accessibilityIdentifier("recordingStatusText")
      }
      .padding()

      Divider()

      VStack(spacing: 2) {

        Text("Keyboard Shortcut")
          .font(.title)
          .padding(.bottom, 2)

        Picker("Edit Shortcut", selection: $newShortcutKey) {
          ForEach("abcdefghijklmnopqrstuvwxyz".map { String($0) }, id: \.self) { key in
            Text(key.lowercased()).tag(key)
          }
        }
        .pickerStyle(MenuPickerStyle())
        .padding()

        HStack(spacing: 2) {
          ForEach(["control", "option", "command"], id: \.self) { modifier in
            Button(action: {
              keyboardShortcutManager.updateShortcutModifier(modifier: modifier)
            }) {
              Text(modifier)
                .font(.subheadline)
                .foregroundColor(.black)
                .padding(3)
                .frame(maxWidth: .infinity)
            }
            .background(
              keyboardShortcutManager.shortcutModifiers.contains(modifier)
                ? Color.green : Color.gray
            )
            .clipShape(Capsule())
            .onHover { hovering in
              if hovering {
                NSCursor.pointingHand.push()
              } else {
                NSCursor.pop()
              }
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityIdentifier("\(modifier)Button")
          }
        }
      }

      Divider()

      Text("Logger")
        .font(.title)
        .padding(.bottom, 2)

      ScrollView {
        Text(verbatim: whisperState.logger)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding()
          .accessibilityIdentifier("loggerText")
      }
      .frame(minHeight: 150)
      .scrollIndicators(.visible)

      Divider()

      Button(action: quit) {
        Text("Quit").padding(1)
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(Color.gray)
      .clipShape(Capsule())
      .accessibilityIdentifier("quitButton")
      .onHover { hovering in
        if hovering {
          NSCursor.pointingHand.push()
        } else {
          NSCursor.pop()
        }
      }
      .buttonStyle(PlainButtonStyle())
    }
    .padding()
  }
}
