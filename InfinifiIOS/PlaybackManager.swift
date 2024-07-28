import AVKit
import Foundation

enum PlaybackState {
    case playing
    case paused
    case loading
}

@MainActor
class PlaybackManager: ObservableObject {
    @Published var playbackState: PlaybackState = .paused
    @Published var hasError = false

    private var audioPlayer = AVPlayer()

    func nextTrack() {
        playbackState = .loading
        Task {
            try await loadCurrentTrack()
            playbackState = .playing
        }
    }

    func stop() {
        playbackState = .paused
        audioPlayer.pause()
    }

    private nonisolated func loadCurrentTrack() async throws {
        let now = Date().timeIntervalSince1970
        guard let url = URL(string: "https://infinifi.cafe/current.mp3?t=\(now)") else {
            return
        }

        // add timestamp to the url to prevent caching
        let asset = AVAsset(url: url)
        let isPlayable = try await asset.load(.isPlayable)
        guard isPlayable else {
            return
        }

        let playerItem = AVPlayerItem(asset: asset)

        NotificationCenter.default.addObserver(self, selector: #selector(playbackFinished), name: AVPlayerItem.didPlayToEndTimeNotification, object: playerItem)

        await audioPlayer.replaceCurrentItem(with: playerItem)
        await audioPlayer.play()
    }

    @objc
    private func playbackFinished() {
        NotificationCenter.default.removeObserver(self, name: AVPlayerItem.didPlayToEndTimeNotification, object: audioPlayer.currentItem)
        if playbackState == .playing {
            nextTrack()
        }
    }
}
