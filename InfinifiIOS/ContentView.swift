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
        }
    }

    var body: some View {
        let buttonImageName = switch playbackManager.playbackState {
        case .paused: "play"
        case .playing: "pause"
        }

        VStack(alignment: .center) {
            Text("infinifi")
                .font(.title3)
                .bold()
                .monospaced()
                .padding()

            Spacer()

            NeuButton(action: {
                toggleAudioPlayback()
            }) {
                Image(systemName: buttonImageName)
                    .font(.system(size: 24))
                    .tint(.text)
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
