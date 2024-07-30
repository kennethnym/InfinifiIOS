import Combine
import Foundation
import Network
import SwiftUI

let webSocketMaxReconnectionCount = 3

class LiveStatusManager: NSObject, ObservableObject, URLSessionWebSocketDelegate {
    @Published var listenerCount: Int = -1

    @ObservedObject private var playbackManager: PlaybackManager

    private let pathMonitor = NWPathMonitor()

    private var ws: URLSessionWebSocketTask?
    private var playbackStateObserver: AnyCancellable?
    private var retryCount = 0

    init(playbackManager: PlaybackManager) {
        self.playbackManager = playbackManager
        super.init()

        playbackStateObserver = playbackManager.$playbackState.sink { playbackState in
            self.onPlaybackStateChanged(playbackState)
        }

        pathMonitor.pathUpdateHandler = { path in
            self.onNetworkChanged(path)
        }

        connectToWebSocket()
    }

    deinit {
        ws?.cancel(with: .goingAway, reason: nil)
        pathMonitor.cancel()
    }

    func connectToWebSocket() {
        guard let url = URL(string: "wss://infinifi.cafe/ws") else {
            return
        }

        let req = URLRequest(url: url)
        let ws = URLSession.shared.webSocketTask(with: req)
        ws.delegate = self
        ws.resume()

        self.ws = ws
        receiveWebSocketMessage()
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        if retryCount == webSocketMaxReconnectionCount {
            DispatchQueue.main.async {
                self.listenerCount = -1
            }
        } else {
            retryCount += 1
            connectToWebSocket()
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        if retryCount == webSocketMaxReconnectionCount {
            DispatchQueue.main.async {
                self.listenerCount = -1
            }
        } else {
            retryCount += 1
            connectToWebSocket()
        }
    }

    private func receiveWebSocketMessage() {
        ws?.receive { result in
            switch result {
            #if DEBUG
            case .failure(let err):
                print("failed to received \(err)")
            #endif
            case .success(.string(let msg)):
                self.retryCount = 0
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

    private func onNetworkChanged(_ path: NWPath) {
        if path.status == .satisfied {
            if retryCount > 0 {
                retryCount = 0
            }
            retryCount += 1
            connectToWebSocket()
        }
    }
}
