import Combine
import Foundation
import SwiftUI

let effectRadius: Float = 100
let minDotRadius: Float = 1

struct DottedBackground: View {
    @State private var isDragging = false
    @State private var touchX: Float = 0
    @State private var touchY: Float = 0
    @State private var hapticsCooldownTimer: Timer?

    private let impactGenerator = UIImpactFeedbackGenerator(style: .soft)

    var body: some View {
        let dragGesture = DragGesture(minimumDistance: 0)
            .onChanged { value in
                isDragging = true
                touchX = Float(value.location.x)
                touchY = Float(value.location.y)

                if hapticsCooldownTimer == nil {
                    impactGenerator.impactOccurred()
                    hapticsCooldownTimer = Timer.scheduledTimer(withTimeInterval: 1 / 60, repeats: false) { _ in
                        self.hapticsCooldownTimer = nil
                    }
                }
            }
            .onEnded { _ in
                isDragging = false
            }

        Canvas { ctx, size in
            for y in stride(from: 0, to: Int(size.height), by: 10) {
                for x in stride(from: 0, to: Int(size.width), by: 10) {
                    let radius: CGFloat
                    if isDragging {
                        let distanceFromTouch = sqrt(pow(Float(x) - touchX, 2) + pow(Float(y) - touchY, 2))
                        let howCloseToOrigin: Float = (effectRadius - min(effectRadius, distanceFromTouch)) / 100
                        radius = CGFloat(minDotRadius + minDotRadius * 2 * howCloseToOrigin)
                    } else {
                        radius = CGFloat(minDotRadius)
                    }

                    ctx.fill(
                        Path(ellipseIn: CGRect(origin: CGPoint(x: x, y: y), size: CGSizeMake(radius * 2, radius * 2))),
                        with: .color(.surface1)
                    )
                }
            }
        }
        .gesture(dragGesture)
    }
}
