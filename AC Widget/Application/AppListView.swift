//
//  AppSelectionView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct AppListView: View {
    let apps: [ACApp]

    var body: some View {
        if apps.isEmpty {
            Text("NO_APPS")
        } else {
            List(apps) { app in
                HStack {
                    AsyncImage(url: URL(string: app.artworkUrl60)) { image in
                        image.resizable()
                    } placeholder: {
                        Rectangle().foregroundColor(.secondary)
                    }
                    .frame(width: 30, height: 30)
                    .cornerRadius(7)

                    if let url = URL(string: "https://apps.apple.com/us/app/id" + app.appstoreId) {
                        Link(app.name, destination: url)
                    } else {
                        Text(app.name)
                    }
                }
                .padding(.vertical, 3)
            }
        }
    }
}

struct AppSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AppListView(apps: [
                ACApp(appstoreId: "1", name: "My first App", sku: "", version: "", currentVersionReleaseDate: "", artworkUrl60: "", artworkUrl100: ""),
                ACApp.mockApp,
                ACApp(appstoreId: "3", name: "My pretty App", sku: "", version: "", currentVersionReleaseDate: "", artworkUrl60: "", artworkUrl100: ""),
                ACApp(appstoreId: "4", name: "My ugly App", sku: "", version: "", currentVersionReleaseDate: "", artworkUrl60: "", artworkUrl100: ""),
                ACApp(appstoreId: "5", name: "My awesome App", sku: "", version: "", currentVersionReleaseDate: "", artworkUrl60: "", artworkUrl100: ""),
            ])
        }
    }
}
