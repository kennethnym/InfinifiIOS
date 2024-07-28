import AVKit
import Foundation

enum PlaybackState {
    case playing
    case paused
}

class PlaybackManager: ObservableObject {
    @Published var playbackState: PlaybackState = .paused
    @Published var hasError = false

    private var audioPlayer = AVPlayer()

    func nextTrack() {
        let now = Date().timeIntervalSince1970
        // add timestamp to the url to prevent caching
        let playerItem = AVPlayerItem(url: URL(string: "https://infinifi.cafe/current.mp3?t=\(now)")!)
        NotificationCenter.default.addObserver(self, selector: #selector(playbackFinished), name: AVPlayerItem.didPlayToEndTimeNotification, object: playerItem)

        audioPlayer.replaceCurrentItem(with: playerItem)
        audioPlayer.play()

        playbackState = .playing
    }

    func stop() {
        audioPlayer.pause()
        playbackState = .paused
    }

    @objc
    private func playbackFinished() {
        NotificationCenter.default.removeObserver(self, name: AVPlayerItem.didPlayToEndTimeNotification, object: audioPlayer.currentItem)
        if playbackState == .playing {
            nextTrack()
        }
    }
}
