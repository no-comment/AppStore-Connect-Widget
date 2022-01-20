//
//  UpdateDetailView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct UpdateDetailView: View {
    @Environment(\.colorScheme) private var scheme
    private var icon: Image
    private var title: LocalizedStringKey
    private var subTitle: LocalizedStringKey

    init(systemName: String, title: LocalizedStringKey, subTitle: LocalizedStringKey) {
        self.icon = Image(systemName: systemName)
        self.title = title
        self.subTitle = subTitle
    }

    init(imageName: String, title: LocalizedStringKey, subTitle: LocalizedStringKey) {
        self.icon = Image(imageName)
        self.title = title
        self.subTitle = subTitle
    }

    var body: some View {
        HStack(alignment: .center) {
            ZStack(alignment: .center) {
                Rectangle()
                    .foregroundColor(.accentColor.opacity(scheme == .dark ? 0.2 : 1))
                    .frame(width: 40, height: 40)
                icon
                    .foregroundColor(scheme == .dark ? .accentColor : .white)
                    .font(.system(size: 40 * 0.425, weight: .medium))
            }
            .cornerRadius(5)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibility(addTraits: .isHeader)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)

                Text(subTitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct UpdateDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack(alignment: .leading) {
                UpdateDetailView(systemName: "icloud", title: "iCloud Sync", subTitle: "This App now syncs via automatically iCloud.")
                UpdateDetailView(imageName: "logo.github", title: "Open Source", subTitle: "This App is open source.")
            }

            VStack(alignment: .leading) {
                UpdateDetailView(systemName: "icloud", title: "iCloud Sync", subTitle: "This App now syncs via automatically iCloud.")
                UpdateDetailView(imageName: "logo.github", title: "Open Source", subTitle: "This App is open source.")
            }
            .preferredColorScheme(.dark)
        }
    }
}
