import AVFoundation
import SwiftUI

struct CustomButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding()
      .background(configuration.isPressed ? Color.blue.opacity(0.7) : Color.blue)
      .foregroundColor(.white)
      .cornerRadius(10)
      .shadow(radius: configuration.isPressed ? 0 : 10)
      .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
  }
}

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
