//
//  KeySelectionView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct KeySelectionView: View {
    @AppStorage(UserDefaultsKey.homeSelectedKey, store: UserDefaults.shared) private var keyID: String = ""
    @AppStorage(UserDefaultsKey.homeApps, store: UserDefaults.shared) private var homeApps: String = ""
    @AppStorage(UserDefaultsKey.homeCurrency, store: UserDefaults.shared) private var currency: String = Currency.USD.rawValue
    private var selectedKey: APIKey? {
        return APIKey.getApiKey(apiKeyId: keyID)
    }
    @State var apps: [ACApp] = []

    var body: some View {
        Form {
            keySelection
            appSelection
            currencySelection
        }
        .onChange(of: keyID, perform: { _ in loadApps() })
        .onAppear(perform: loadApps)
        .navigationTitle("SELECT_KEY")
    }

    var keySelection: some View {
        Section(header: Label("API_KEY", systemImage: "key.fill")) {
            ForEach(APIKey.getApiKeys()) { key in
                Button(action: { keyID = key.id }, label: {
                    HStack {
                        Text("\(Image(systemName: "circle.fill"))")
                            .foregroundColor(key.color)
                        Text(key.name)
                        Spacer()
                        if key.id == selectedKey?.id {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.accentColor)
                        }
                    }
                })
            }
        }
    }

    var appSelection: some View {
        Section(header: Label("APPLICATIONS", systemImage: "app.fill")) {
            ForEach(apps, id: \.id) { (app: ACApp) in
                Button(action: {
                    if homeApps.contains(app.id) {
                        homeApps = homeApps.split(separator: ",").filter({ $0 != app.id }).joined(separator: ",")
                    } else {
                        homeApps.append(",\(app.id)")
                    }
                }, label: {
                    HStack {
                        Text(app.name)
                        Spacer()
                        if homeApps.contains(app.id) {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.accentColor)
                        }
                    }
                })
            }
        }
    }

    var currencySelection: some View {
        Section(header: Label("CURRENCY", systemImage: "dollarsign.circle.fill")) {
            Picker("App Currency", selection: $currency) {
                ForEach(Currency.sortedAllCases, id: \.rawValue) { currency in
                    Text(currency.rawValue)
                }
            }
        }
    }

    func loadApps() {
        apps = []
        guard let key = selectedKey else { return }
        AppStoreConnectApi(apiKey: key).getData()
            .then { data in
                apps = data.apps
            }
    }
}

struct KeySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            KeySelectionView()
        }
    }
}
