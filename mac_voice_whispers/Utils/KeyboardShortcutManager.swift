import HotKey
import SwiftUI

@MainActor
class KeyboardShortcutManager: ObservableObject {
  @AppStorage("shortcutKey") var shortcutKey: String = "r"
  @AppStorage("shortcutModifiers") var shortcutModifiers: String = "control,option"

  @Published var whisperState: WhisperState
  private var hotkey: HotKey?

  init(whisperState: WhisperState) {
    self.whisperState = whisperState
    setupHotKey()
  }

  private func setupHotKey() {
    print(shortcutKey)
    print(shortcutModifiers)
    guard let key = Key(string: shortcutKey) else {
      print("Invalid key")
      return
    }

    let modifiers = modifierFlags(from: shortcutModifiers)
    hotkey = HotKey(key: key, modifiers: modifiers)
    hotkey?.keyDownHandler = {
      Task {
        await self.whisperState.toggleRecord()
      }
    }
  }

  func updateShortcutKey(key: String) {
    shortcutKey = key
    setupHotKey()
  }

  func updateShortcutModifier(modifier: String) {
    var modifiersSet = Set(shortcutModifiers.split(separator: ",").map(String.init))

    if modifiersSet.contains(modifier) {
      modifiersSet.remove(modifier)
    } else {
      modifiersSet.insert(modifier)
    }

    shortcutModifiers = modifiersSet.joined(separator: ",")

    setupHotKey()
    print("hot keys changed to")
    print(shortcutKey)
    print(shortcutModifiers)
  }

}
