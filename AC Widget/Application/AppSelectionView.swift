//
//  AppSelectionView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct AppSelectionView: View {
    @AppStorage(UserDefaultsKey.homeSelectedKey, store: UserDefaults.shared) private var keyID: String = ""
    @AppStorage(UserDefaultsKey.homeSelectedApps, store: UserDefaults.shared) private var selectedAppsString: String = ""
    @State var apps: [ACApp] = []
    var selectedApps: [ACApp] {
        let ids = selectedAppsString.split(separator: ";").map({ String($0) })
        return apps.filter { ids.contains($0.id) }
    }

    var body: some View {
        List(apps) { item in
            Button(action: { select(app: item) }) {
                HStack {
                    AsyncImage(url: URL(string: item.artworkUrl60)) { image in
                        image.resizable()
                    } placeholder: {
                        Rectangle().foregroundColor(.secondary)
                    }
                    .frame(width: 30, height: 30)
                    .cornerRadius(7)

                    Text(item.name)
                    Spacer()
                    if selectedApps.contains(where: { $0.id == item.id }) {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.accentColor)
                    }
                }
                .padding(.vertical, 3)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .navigationTitle("SELECT_APPS")
        .onAppear(perform: onAppear)
    }

    private func select(app: ACApp) {
        if selectedApps.contains(where: { $0.id == app.id }) {
            var tempApps = selectedApps
            tempApps.removeAll(where: { $0.id == app.id })
            selectedAppsString = tempApps.map({ $0.id }).joined(separator: ";")
        } else {
            selectedAppsString.append(";\(app.id)")
        }
    }

    private func onAppear() {
        guard let apiKey = APIKey.getApiKey(apiKeyId: keyID) ?? APIKey.getApiKeys().first else { return }
        let api = AppStoreConnectApi(apiKey: apiKey)
        api.getData(currency: Currency(rawValue: "USD"), useCache: true).then { (data) in
            self.apps = data.apps
        }
    }
}

struct AppSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AppSelectionView(apps: [
                ACApp(appstoreId: "1", name: "My first App", sku: "", version: "", currentVersionReleaseDate: "", artworkUrl60: "", artworkUrl100: ""),
                ACApp.mockApp,
                ACApp(appstoreId: "3", name: "My pretty App", sku: "", version: "", currentVersionReleaseDate: "", artworkUrl60: "", artworkUrl100: ""),
                ACApp(appstoreId: "4", name: "My ugly App", sku: "", version: "", currentVersionReleaseDate: "", artworkUrl60: "", artworkUrl100: ""),
                ACApp(appstoreId: "5", name: "My awesome App", sku: "", version: "", currentVersionReleaseDate: "", artworkUrl60: "", artworkUrl100: ""),
            ])
        }
    }
}
