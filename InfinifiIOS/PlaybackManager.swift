import AVKit
import Foundation

enum PlaybackState {
    case playing
    case paused
    case loading
}

class PlaybackManager: ObservableObject {
    @Published var playbackState: PlaybackState = .paused
    @Published var hasError = false

    private var audioPlayer = AVPlayer()
    private var fadeInTimer: Timer?
    private var fadeOutTimer: Timer?
    private var scheduledFadeOutTimer: Timer?

    func nextTrack() {
        playbackState = .loading
        Task {
            try await loadAndPlayNextTrack()
            await MainActor.run {
                playbackState = .playing
            }
        }
    }

    func stop() {
        playbackState = .paused
        fadeInTimer?.invalidate()
        fadeInTimer = nil
        fadeOutTimer?.invalidate()
        fadeOutTimer = nil
        scheduledFadeOutTimer?.invalidate()
        scheduledFadeOutTimer = nil
        audioPlayer.pause()
    }

    private nonisolated func loadAndPlayNextTrack() async throws {
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

        audioPlayer.volume = 0.0

        audioPlayer.replaceCurrentItem(with: playerItem)
        await audioPlayer.play()

        DispatchQueue.main.async {
            self.fadeInAudio()
            self.scheduledFadeOutTimer = Timer.scheduledTimer(withTimeInterval: 55, repeats: false) { _ in
                self.fadeOutAudio()
            }
        }
    }

    @objc
    private func playbackFinished() {
        NotificationCenter.default.removeObserver(self, name: AVPlayerItem.didPlayToEndTimeNotification, object: audioPlayer.currentItem)
        if playbackState == .playing {
            nextTrack()
        }
    }

    private func fadeInAudio() {
        fadeInTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            self.audioPlayer.volume += 0.01
            if self.audioPlayer.volume >= 1.0 {
                timer.invalidate()
            }
        }
    }

    private func fadeOutAudio() {
        fadeOutTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            self.audioPlayer.volume -= 0.02
            if self.audioPlayer.volume <= 0 {
                timer.invalidate()
            }
        }
    }
}
