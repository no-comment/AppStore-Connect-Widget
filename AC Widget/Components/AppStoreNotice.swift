//
//  AppStoreNotice.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct AppStoreNotice: View {
    @AppStorage(UserDefaultsKey.appStoreNotice, store: UserDefaults.shared) private var appStoreNotice: Bool = true

    var body: some View {
        Card(spacing: 15) {
            Image("logo.appstore")
                .font(.system(size: 50))
                .foregroundColor(.accentColor)

            Text("APPSTORE_NOTICE")
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .foregroundColor(.accentColor)

            Text("APPSTORE_NOTICE_TEXT")

            HStack {
                Button("DISMISS", action: { appStoreNotice = false })
                    .buttonStyle(.bordered)

                if let destination = URL(string: "https://apps.apple.com/app/ac-widget/id1562025981") {
                    Link(destination: destination, label: {
                        Label("APPSTORE_NOTICE_PROMPT", image: "logo.appstore")
                        // Text("APPSTORE_NOTICE_PROMPT")
                    })
                        .buttonStyle(.borderedProminent)
                }
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: 450)
        .padding()
    }

    public static func isTestFlight() -> Bool {
        guard let path = Bundle.main.appStoreReceiptURL?.path else {
            return false
        }
        return path.contains("sandboxReceipt")
    }
}

struct AppStoreNotice_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppStoreNotice()
            AppStoreNotice()
                .preferredColorScheme(.dark)
        }
    }
}
