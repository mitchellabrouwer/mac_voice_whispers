import HotKey
import SwiftUI

@main
struct WhisperCppApp: App {
  @StateObject private var appState = AppState.shared

  var body: some Scene {

    MenuBarExtra("UtilityApp", systemImage: "mic") {
      AppMenu(appState: appState)
    }.menuBarExtraStyle(.window)

    WindowGroup {}

  }

}
