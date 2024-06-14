import XCTest

@testable import mac_voice_whispers

final class mac_voice_whispersTests: XCTestCase {

  var whisperState: WhisperState!

  override func setUpWithError() throws {
    try super.setUpWithError()
    // use task to initialize whisperState whithin the main actor context
    Task { @MainActor in
      self.whisperState = WhisperState()
    }
  }

  override func tearDownWithError() throws {
    Task { @MainActor in
      self.whisperState = nil
    }
    try super.tearDownWithError()
  }

  func testModelLoadsCorrectly() async throws {
    await Task { @MainActor in
      XCTAssertTrue(
        self.whisperState.canTranscribe, "Model should be loaded and able to transcribe.")
    }.value
  }

  func testTranscribeAudioFile() async throws {
    guard let testAudioURL: URL = Bundle(for: type(of: self)).url(forResource: "testAudioAgain", withExtension: "wav")
    else {
      XCTFail("Sample wav file not found")
      return
    }

    await Task { @MainActor in
        await self.whisperState.transcribeSample(sampleUrl: testAudioURL)
      XCTAssertFalse(
        self.whisperState.transcribedMessage.isEmpty, "Transcription message should not be empty.")
      XCTAssertEqual(
        self.whisperState.transcribedMessage, " Hi, how are you? What's going on today?",
        "The transcription did not match the expected text.")
    }.value
  }

}
