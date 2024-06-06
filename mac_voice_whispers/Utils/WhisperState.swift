import AVFoundation
import ApplicationServices
import Carbon
import Cocoa
import CoreGraphics
import Foundation
import Quartz
import SwiftUI

@MainActor
class WhisperState: NSObject, ObservableObject, AVAudioRecorderDelegate {
  @Published var isModelLoaded = false
  @Published var messageLog = ""
  @Published var canTranscribe = false
  @Published var isRecording = false

  private var whisperContext: WhisperContext?
  private let recorder = Recorder()
  private var recordedFile: URL? = nil
  private var audioPlayer: AVAudioPlayer?

  private var modelUrl: URL? {
    Bundle.main.url(forResource: "ggml-tiny.en", withExtension: "bin")
  }

  private var sampleUrl: URL? {
    Bundle.main.url(forResource: "jfk", withExtension: "wav", subdirectory: "samples")
  }

  private enum LoadError: Error {
    case couldNotLocateModel
  }

  override init() {
    super.init()
    do {
      try loadModel()
      canTranscribe = true
    } catch {
      print(error.localizedDescription)
      messageLog += "\(error.localizedDescription)\n"
    }
  }

  private func loadModel() throws {
    messageLog += "Loading model...\n"
    if let modelUrl {
      whisperContext = try WhisperContext.createContext(path: modelUrl.path())
      messageLog += "Loaded model \(modelUrl.lastPathComponent)\n"
    } else {
      messageLog += "Could not locate model\n"
    }
  }

  func transcribeSample() async {
    if let sampleUrl {
      await transcribeAudio(sampleUrl)
    } else {
      messageLog += "Could not locate sample\n"
    }
  }

  private func transcribeAudio(_ url: URL) async {
    if !canTranscribe {
      return
    }
    guard let whisperContext else {
      return
    }

    do {
      canTranscribe = false
      messageLog += "Reading wave samples...\n"
      let data = try readAudioSamples(url)
      messageLog += "Transcribing data...\n"
      await whisperContext.fullTranscribe(samples: data)
      let text = await whisperContext.getTranscription()
      messageLog += "Done: \(text)\n"
    } catch {
      print(error.localizedDescription)
      messageLog += "\(error.localizedDescription)\n"
    }

    canTranscribe = true
  }

  private func readAudioSamples(_ url: URL) throws -> [Float] {
    stopPlayback()
    try startPlayback(url)
    return try decodeWaveFile(url)
  }

  func toggleRecord() async {
    if isRecording {
      await recorder.stopRecording()
      isRecording = false
      if let recordedFile {
        await transcribeAudio(recordedFile)
        insertText(text: messageLog)
      }
    } else {
      requestRecordPermission { granted in
        if granted {
          Task {
            do {
              self.stopPlayback()
              let file = try FileManager.default.url(
                for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true
              )
              .appending(path: "output.wav")
              try await self.recorder.startRecording(toOutputFile: file, delegate: self)
              self.isRecording = true
              self.recordedFile = file
            } catch {
              print(error.localizedDescription)
              self.messageLog += "\(error.localizedDescription)\n"
              self.isRecording = false
            }
          }
        }
      }
    }
  }

  private func requestRecordPermission(response: @escaping (Bool) -> Void) {
    #if os(macOS)
      response(true)
    #else
      AVAudioSession.sharedInstance().requestRecordPermission { granted in
        response(granted)
      }
    #endif
  }

  private func startPlayback(_ url: URL) throws {
    audioPlayer = try AVAudioPlayer(contentsOf: url)
    audioPlayer?.play()
  }

  private func stopPlayback() {
    audioPlayer?.stop()
    audioPlayer = nil
  }

  nonisolated func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
    if let error {
      Task {
        await handleRecError(error)
      }
    }
  }

  private func handleRecError(_ error: Error) {
    print(error.localizedDescription)
    messageLog += "\(error.localizedDescription)\n"
    isRecording = false
  }

  nonisolated func audioRecorderDidFinishRecording(
    _ recorder: AVAudioRecorder, successfully flag: Bool
  ) {
    Task {
      await onDidFinishRecording()
    }
  }

  private func onDidFinishRecording() {
    isRecording = false
  }

  func insertText(text: String) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(text, forType: .string)

    guard let source = CGEventSource(stateID: .hidSystemState) else {
      print("Unable to create event source")
      return
    }

    let commandKeyDown = CGEvent(
      keyboardEventSource: source, virtualKey: CGKeyCode(kVK_Command), keyDown: true)
    let vKeyDown = CGEvent(
      keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: true)
    let vKeyUp = CGEvent(
      keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: false)
    let commandKeyUp = CGEvent(
      keyboardEventSource: source, virtualKey: CGKeyCode(kVK_Command), keyDown: false)

    vKeyDown?.flags = .maskCommand
    vKeyUp?.flags = .maskCommand

    commandKeyDown?.post(tap: .cghidEventTap)
    vKeyDown?.post(tap: .cghidEventTap)
    vKeyUp?.post(tap: .cghidEventTap)
    commandKeyUp?.post(tap: .cghidEventTap)
  }
}
