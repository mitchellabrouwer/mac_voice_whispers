import SwiftUI

struct RecordingIndicator: View {
  var isLoading: Bool

  var body: some View {
    ZStack {
      Circle()
        .fill(isLoading ? Color.yellow : Color.red)
        .frame(width: 30, height: 30)
        .accessibilityIdentifier(isLoading ? "yellowProgressLoader" : "redProgressLoader")
      ProgressView()
        .progressViewStyle(CircularProgressViewStyle())
    }
  }
}
