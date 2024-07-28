import AVKit
import SwiftUI

struct ContentView: View {
    @ObservedObject private var playbackManager = PlaybackManager()

    private func toggleAudioPlayback() {
        switch playbackManager.playbackState {
        case .playing:
            playbackManager.stop()
        case .paused:
            playbackManager.nextTrack()
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
