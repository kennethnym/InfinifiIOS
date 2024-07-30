import Foundation
import SwiftUI

struct TitleBar: View {
    @State private var isSettingsOpen = false

    var body: some View {
        HStack(alignment: .center) {
            Spacer()

            Text("infinifi")
                .font(.system(.title3, design: .monospaced))
                .fontWeight(.bold)
                .padding()
                // offset the title down vertically by a bit to optically align with the settings button
                .offset(x: 0, y: 4)

            Spacer().overlay {
                NeuButton(action: {
                    isSettingsOpen.toggle()
                }) {
                    Image(systemName: "info.square.fill")
                        .font(.system(size: 16))
                        .tint(.text)
                }
                .frame(width: 32, height: 32)
            }
        }
        .sheet(isPresented: $isSettingsOpen, content: {
            AboutPage()
        })
    }
}
