//
//  UpdateDetailView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct UpdateDetailView: View {
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
            icon
                .font(.largeTitle)
                .frame(width: 50.0, height: 50.0)
                .padding(.trailing)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibility(addTraits: .isHeader)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)

                Text(subTitle)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top)
    }
}

struct UpdateDetailView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            UpdateDetailView(systemName: "icloud", title: "iCloud Sync", subTitle: "This App now syncs via automatically iCloud.")
            UpdateDetailView(imageName: "logo.github", title: "Open Source", subTitle: "This App is open source.")
        }
    }
}
