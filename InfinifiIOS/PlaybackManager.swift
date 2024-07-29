import AVKit
import Foundation
import MediaPlayer

enum PlaybackState {
    case playing
    case paused
    case loading
    case initializing
}

class PlaybackManager: ObservableObject {
    @Published var playbackState: PlaybackState = .initializing
    @Published var hasError = false

    private var audioPlayer = AVPlayer()
    private var fadeInTimer: Timer?
    private var fadeOutTimer: Timer?
    private var scheduledFadeOutTimer: Timer?

    init() {
        Task { try await initialize() }
    }

    func confiugureAudioSessionAndControls() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {}

        NotificationCenter.default.addObserver(self, selector: #selector(onAudioInterrupted), name: AVAudioSession.interruptionNotification, object: audioSession)

        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: "infinite lo-fi music",
            MPMediaItemPropertyArtist: "infinifi"
        ]

        let cmdCenter = MPRemoteCommandCenter.shared()

        cmdCenter.playCommand.isEnabled = true
        cmdCenter.playCommand.addTarget { _ in
            self.nextTrack()
            return .success
        }

        cmdCenter.pauseCommand.isEnabled = true
        cmdCenter.pauseCommand.addTarget { _ in
            self.stop()
            return .success
        }
    }

    func nextTrack() {
        playbackState = .loading
        Task {
            try await loadNextTrack()
            await playCurrentTrack()
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

    private func initialize() async throws {
        try await loadNextTrack()

        await MainActor.run {
            playbackState = .paused
        }
    }

    private nonisolated func loadNextTrack() async throws {
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
    }

    private nonisolated func playCurrentTrack() async {
        await audioPlayer.play()
        DispatchQueue.main.async {
            self.fadeInAudio()
            self.scheduledFadeOutTimer = Timer.scheduledTimer(withTimeInterval: 55, repeats: false) { _ in
                self.fadeOutAudio()
            }
        }
    }

    @objc
    private func onAudioInterrupted(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let interruptionType = AVAudioSession.InterruptionType(rawValue: typeValue)
        else {
            return
        }

        switch interruptionType {
        case .began:
            DispatchQueue.main.async {
                self.stop()
            }

        case .ended:
            guard let optionValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {
                return
            }

            let options = AVAudioSession.InterruptionOptions(rawValue: optionValue)
            if options.contains(.shouldResume) {
                DispatchQueue.main.async {
                    self.nextTrack()
                }
            }

        @unknown default:
            break
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
