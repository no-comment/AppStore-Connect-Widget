//
//  UpdateDetailView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct UpdateDetailView: View {
    var systemName: String
    var title: LocalizedStringKey
    var subTitle: LocalizedStringKey

    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: systemName)
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
        UpdateDetailView(systemName: "icloud", title: "iCloud Sync", subTitle: "This App now syncs via automatically iCloud.")
    }
}
