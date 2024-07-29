import Foundation
import SwiftUI

struct LiveListenerCounter: View {
    @StateObject private var liveStatusManager: LiveStatusManager

    init(playbackManager: PlaybackManager) {
        _liveStatusManager = StateObject(wrappedValue: LiveStatusManager(playbackManager: playbackManager))
    }

    var body: some View {
        let text = if liveStatusManager.listenerCount >= 0 && liveStatusManager.listenerCount <= 1 {
            "\(liveStatusManager.listenerCount) person tuned in"
        } else if liveStatusManager.listenerCount > 1 {
            "\(liveStatusManager.listenerCount) ppl tuned in"
        } else {
            "connecting"
        }

        Text(text)
            .font(.system(.body, design: .monospaced))
            .padding()
            .opacity(0.8)
    }
}
