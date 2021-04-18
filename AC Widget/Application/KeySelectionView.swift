//
//  KeySelectionView.swift
//  AC Widget
//
//  Created by Cameron Shemilt on 18.04.21.
//

import SwiftUI

struct KeySelectionView: View {
    @AppStorage(UserDefaultsKey.homeSelectedKey, store: UserDefaults.shared) private var keyID: String = ""
    private var selectedKey: APIKey? {
        return APIKey.getApiKey(apiKeyId: keyID)
    }

    var body: some View {
        Form {
            keySelection
            appSelection
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
}

struct KeySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            KeySelectionView()
        }
    }
}
