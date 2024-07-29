import Foundation
import SwiftUI

let effectRadius = 100
let minDotRadius = 1

struct DottedBackground: View {
    @State private var isDragging = false
    @State private var touchX: Float = 0
    @State private var touchY: Float = 0

    var body: some View {
        let dragGesture = DragGesture(minimumDistance: 0)
            .onChanged { value in
                isDragging = true
                touchX = Float(value.location.x)
                touchY = Float(value.location.y)
            }
            .onEnded { _ in
                isDragging = false
            }

        Canvas { ctx, size in
            for y in stride(from: 0, to: Int(size.height), by: 10) {
                for x in stride(from: 0, to: Int(size.width), by: 10) {
                    let radius: Int
                    if isDragging {
                        let distanceFromTouch = Int(sqrt(pow(Float(x) - touchX, 2) + pow(Float(y) - touchY, 2)))
                        radius = minDotRadius + minDotRadius * 4 * (effectRadius - min(effectRadius, distanceFromTouch)) / 100
                    } else {
                        radius = minDotRadius
                    }

                    ctx.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: radius * 2, height: radius * 2)),
                        with: .color(.surface1)
                    )
                }
            }
        }
        .gesture(dragGesture)
    }
}
