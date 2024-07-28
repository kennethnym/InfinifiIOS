import Foundation
import SwiftUI

struct NeuButtonStyle: PrimitiveButtonStyle {
    private let onPressStateChange: (_ isPressed: Bool) -> Void
    private let impact = UIImpactFeedbackGenerator(style: .medium)

    init(onPressStateChange: @escaping (_: Bool) -> Void) {
        self.onPressStateChange = onPressStateChange
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onTapGesture {
                configuration.trigger()
            }
            .onLongPressGesture(minimumDuration: 0) {} onPressingChanged: { isPressing in
                onPressStateChange(isPressing)
                impact.impactOccurred()
            }
    }
}

struct NeuButton<Content>: View where Content: View {
    let content: () -> Content
    let action: () -> Void

    @State private var isPressed = false

    init(action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Rectangle()
                .fill(isPressed ? .base : .text)
                .offset(
                    x: isPressed ? 0 : 4,
                    y: isPressed ? 0 : 4
                )
                .overlay {
                    ZStack {
                        Rectangle()
                            .fill(isPressed ? .text : .base)

                        content()
                            .foregroundStyle(isPressed ? .base : .text)
                    }
                }
        }
        .border(.text, width: 2)
        .frame(width: 64, height: 64)
        .offset(
            x: isPressed ? 6 : 0,
            y: isPressed ? 6 : 0
        )
        .buttonStyle(NeuButtonStyle { isPressed in
            self.isPressed = isPressed
        })
    }
}
