import Combine
import Foundation
import SwiftUI

class LiveStatusManager: ObservableObject {
    @Published var listenerCount: Int = -1

    @ObservedObject private var playbackManager: PlaybackManager
    private var ws: URLSessionWebSocketTask?
    private var playbackStateObserver: AnyCancellable?

    init(playbackManager: PlaybackManager) {
        self.playbackManager = playbackManager
        playbackStateObserver = playbackManager.$playbackState.sink { playbackState in
            self.onPlaybackStateChanged(playbackState)
        }
        connectToWebSocket()
    }

    func connectToWebSocket() {
        guard let url = URL(string: "wss://infinifi.cafe/ws") else {
            return
        }

        let req = URLRequest(url: url)
        let ws = URLSession.shared.webSocketTask(with: req)
        ws.resume()

        self.ws = ws
        receiveWebSocketMessage()
    }

    private func receiveWebSocketMessage() {
        ws?.receive { result in
            switch result {
            #if DEBUG
            case .failure(let err):
                print("failed to received \(err)")
            #endif
            case .success(.string(let msg)):
                self.handleWebSocketMessage(msg)

            default:
                break
            }

            self.receiveWebSocketMessage()
        }
    }

    private func handleWebSocketMessage(_ msg: String) {
        guard let count = Int(msg) else {
            return
        }

        DispatchQueue.main.async {
            self.listenerCount = count
        }
    }

    private func onPlaybackStateChanged(_ playbackState: PlaybackState) {
        guard let ws = ws else {
            return
        }

        switch playbackState {
        case .paused:
            ws.send(.string("paused")) { _ in }
        case .playing:
            ws.send(.string("playing")) { _ in }
        default:
            break
        }
    }
}
