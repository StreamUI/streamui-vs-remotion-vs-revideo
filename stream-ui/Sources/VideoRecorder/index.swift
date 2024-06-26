import AppKit
import ArgumentParser
import Foundation
import MoggedVideo
import StreamUI
import SwiftUI

@Observable
class StreamUISettings {
    var fps: Int32 = 30
    var width: CGFloat = 1080
    var height: CGFloat = 1920
    var captureDuration: Int = 10
    var saveVideoFile: Bool = true

    var livestreamSettings: [LivestreamSettings] = []
}

// Define the command line arguments
struct StreamUICLIArgs: ParsableArguments {
    @Option(help: "Frames per second")
    var fps: Int

    @Option(help: "Width of the video")
    var width: Int

    @Option(help: "Height of the video")
    var height: Int

    @Option(help: "Capture duration in seconds")
    var captureDuration: Int

    @Flag(help: "Save video file")
    var saveVideoFile: Bool = false

    @Option(help: "RTMP connection URL")
    var rtmpConnection: String?

    @Option(help: "Stream key")
    var streamKey: String?
}

extension StreamUICLIArgs {
    func update(_ settings: StreamUISettings) {
        settings.fps = Int32(fps)
        settings.width = CGFloat(width)
        settings.height = CGFloat(height)

        settings.captureDuration = captureDuration
        settings.saveVideoFile = saveVideoFile

        if let rtmpConnection = rtmpConnection, let streamKey = streamKey {
            let livestreamSettings = LivestreamSettings(
                rtmpConnection: rtmpConnection,
                streamKey: streamKey
            )
            settings.livestreamSettings.append(livestreamSettings)
        }
    }
}

@main
enum MyNewExecutable {
    static func main() async throws {
        var settings = StreamUISettings()
        if CommandLine.argc > 1 {
            do {
                let args = try StreamUICLIArgs.parse()
                args.update(settings)
            } catch {
                print("Error: Could not parse arguments")
                print(CommandLine.arguments.dropFirst().joined(separator: " "))
                print(StreamUICLIArgs.helpMessage())
                exit(1) // Exit if argument parsing fails
            }
        }

        print("Starting recorder with the following settings: \(settings)")

        let peopleFetcher = PeopleFetcher()
        let people = await peopleFetcher.fetchPeople()

        print("people", people.count)

        let recorder = createStreamUIRecorder(
            fps: settings.fps,
            width: settings.width,
            height: settings.height,
            displayScale: 2.0,
//            captureDuration: .seconds(settings.captureDuration),
            saveVideoFile: settings.saveVideoFile
//            livestreamSettings: [
//                .init(rtmpConnection: "rtmp://localhost/live", streamKey: "streamKey")
//            ]
        ) {
            VideoView(people: people)
        }

        let controlledClock = recorder.controlledClock

        recorder.startRecording()

        // Uncomment and adjust the following lines as needed for your use case
        // try await Task.sleep(for: .seconds(5))
        // try await controlledClock.sleep(for: 5.0)
        // recorder.pauseRecording()
        // try await Task.sleep(for: .seconds(10))
        // try await controlledClock.sleep(for: 10.0)
        // recorder.resumeRecording()
        // recorder.stopRecording()
        // try await Task.sleep(for: .seconds(2))
        // recorder.resumeRecording()

        // Wait for the recording to complete
        await recorder.waitForRecordingCompletion()
    }
}
