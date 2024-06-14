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
  @Published var logger = ""
  @Published var transcribedMessage = ""
  @Published var canTranscribe = false
  @Published var isRecording = false
  @Published var isLoading = false

  private var whisperContext: WhisperContext?
  private let recorder = Recorder()
  private var recordedFile: URL? = nil

  private var modelUrl: URL? {
    Bundle.main.url(forResource: "ggml-tiny.en", withExtension: "bin")
  }

  private enum LoadError: Error {
    case couldNotLocateModel
  }

  init(isLoaded: Bool) {
    super.init()
    do {
      try loadModel()
      canTranscribe = true
    } catch {
      print(error.localizedDescription)
      logger += "\(error.localizedDescription)\n"
    }
  }

  private func loadModel() throws {
    logger += "Loading model...\n"
    if let modelUrl {
      whisperContext = try WhisperContext.createContext(path: modelUrl.path())
      logger += "Loaded model \(modelUrl.lastPathComponent)\n"
    } else {
      logger += "Could not locate model\n"
    }
  }

  func transcribeSample(sampleUrl: URL) async {
    await transcribeAudio(sampleUrl)
  }

  internal func transcribeAudio(_ url: URL) async {
    if !canTranscribe {
      logger += "Cannot transcribe...\n"
      return
    }

    guard let whisperContext else {
      logger += "Whisper context is nil...\n"
      return
    }

    do {
      canTranscribe = false
      logger += "Reading wave samples...\n"
      let data = try readAudioSamples(url)
      logger += "Read \(data.count) samples.\n"

      logger += "Transcribing data...\n"
      await whisperContext.fullTranscribe(samples: data)

      let text = await whisperContext.getTranscription()
      transcribedMessage = text
    } catch {
      print(error.localizedDescription)
      logger += "\(error.localizedDescription)\n"
    }

    canTranscribe = true
  }

  private func readAudioSamples(_ url: URL) throws -> [Float] {
    return try decodeWaveFile(url)
  }

  func toggleRecord() async {
    if isRecording {
      print("Stopping recording...")
      await recorder.stopRecording()
      isRecording = false
      print("Recording stopped. isRecording: \(isRecording)")
      if let recordedFile {
        isLoading = true
        await transcribeAudio(recordedFile)
        insertText(text: transcribedMessage)
        isLoading = false
      }
    } else {
      requestRecordPermission { granted in
        if granted {
          Task {
            do {
              print("Starting recording...")

              let file = try FileManager.default.url(
                for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true
              )
              .appending(path: "output.wav")
              try await self.recorder.startRecording(toOutputFile: file, delegate: self)
              DispatchQueue.main.async {
                self.isRecording = true
                self.recordedFile = file
                print("Recording started. isRecording \(self.isRecording)")
              }

            } catch {
              print(error.localizedDescription)
              self.logger += "\(error.localizedDescription)\n"
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

  nonisolated func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
    if let error {
      Task {
        await handleRecError(error)
      }
    }
  }

  private func handleRecError(_ error: Error) {
    print(error.localizedDescription)
    logger += "\(error.localizedDescription)\n"
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

  nonisolated func audioRecorderDidFinishRecording(
    _ recorder: AVAudioRecorder, successfully flag: Bool
  ) {
    Task {
      await onDidFinishRecording()
    }
  }

  private func onDidFinishRecording() {
    isRecording = false
    print("Recording finished. isRecording: \(isRecording)")

  }

}
