import AVKit
import SwiftUI

struct ContentView: View {
    @StateObject private var playbackManager = PlaybackManager()

    private func toggleAudioPlayback() {
        switch playbackManager.playbackState {
        case .playing:
            playbackManager.stop()
        case .paused:
            playbackManager.nextTrack()
            Task {
                // sleep for 100ms before configuring audio session and control
                // to prevent UI stutter
                try await Task.sleep(nanoseconds: 100_000_000)
                playbackManager.confiugureAudioSessionAndControls()
            }
        default:
            break
        }
    }

    var body: some View {
        let buttonImageName = switch playbackManager.playbackState {
        case .paused: "play"
        case .playing: "pause"
        case .loading: "dot.square"
        default: ""
        }

        VStack(alignment: .center) {
            Text("infinifi")
                .font(.system(.title3, design: .monospaced))
                .fontWeight(.bold)
                .padding()

            Spacer()

            if playbackManager.playbackState != .initializing {
                NeuButton(action: {
                    toggleAudioPlayback()
                }) {
                    Image(systemName: buttonImageName)
                        .font(.system(size: 24))
                        .tint(.text)
                }
            }

            Spacer()

            LiveListenerCounter(
                playbackManager: playbackManager
            )
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .background(.base)
    }
}

#Preview {
    ContentView()
}
