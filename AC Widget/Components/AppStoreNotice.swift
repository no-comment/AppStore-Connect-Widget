//
//  AppStoreNotice.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct AppStoreNotice: View {
    var body: some View {
        Card(spacing: 15) {
            Text("APPSTORE_NOTICE")
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .foregroundColor(.accentColor)

            Text("APPSTORE_NOTICE_TEXT")

            if let destination = URL(string: "https://apps.apple.com/app/ac-widget/id1562025981") {
                Link(destination: destination, label: {
                    Text("APPSTORE_NOTICE_PROMPT")
                })
                    .buttonStyle(.borderedProminent)
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
