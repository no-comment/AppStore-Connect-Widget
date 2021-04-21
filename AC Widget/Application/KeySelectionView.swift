//
//  KeySelectionView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct KeySelectionView: View {
    @AppStorage(UserDefaultsKey.homeSelectedKey, store: UserDefaults.shared) private var keyID: String = ""
    @AppStorage(UserDefaultsKey.homeCurrency, store: UserDefaults.shared) private var currency: String = "USD"
    private var selectedKey: APIKey? {
        return APIKey.getApiKey(apiKeyId: keyID)
    }

    var body: some View {
        Form {
            keySelection
            appSelection
            currencySelection
        }
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
            Text("TODO")
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
}

struct KeySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            KeySelectionView()
        }
    }
}
