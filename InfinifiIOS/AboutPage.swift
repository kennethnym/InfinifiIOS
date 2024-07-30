import Foundation
import SwiftUI

struct AboutPage: View {
    private func openLink(string: String) {
        guard let url = URL(string: string),
              UIApplication.shared.canOpenURL(url)
        else {
            return
        }
        UIApplication.shared.open(url)
    }

    var body: some View {
        VStack {
            Text("about infinifi")
                .font(.system(.title3, design: .monospaced))
                .fontWeight(.bold)
                .padding()

            Spacer()

            VStack(spacing: 24) {
                NeuButton(action: {
                    openLink(string: sourceCodeURL)
                }) {
                    Text("source code")
                        .font(.system(.body, design: .monospaced))
                }
                .frame(maxWidth: .infinity, maxHeight: 40)

                NeuButton(action: {
                    openLink(string: xURL)
                }) {
                    Text("my twitter")
                        .font(.system(.body, design: .monospaced))
                }
                .frame(maxWidth: .infinity, maxHeight: 40)

                NeuButton(action: {
                    openLink(string: githubURL)
                }) {
                    Text("my github")
                        .font(.system(.body, design: .monospaced))
                }
                .frame(maxWidth: .infinity, maxHeight: 40)

                NeuButton(action: {
                    openLink(string: emailURL)
                }) {
                    Text("my email")
                        .font(.system(.body, design: .monospaced))
                }
                .frame(maxWidth: .infinity, maxHeight: 40)
            }
            .padding()

            Spacer()

            HStack {
                Spacer()
                Image(uiImage: UIImage(named: "EepingCat")!)
                    .resizable()
                    .frame(width: 36, height: 18, alignment: .trailing)
                    .padding(.trailing)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.base)
    }
}

#Preview {
    AboutPage()
}
