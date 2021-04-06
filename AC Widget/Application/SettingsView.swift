//
//  SettingsView.swift
//  AC Widget
//
//  Created by Cameron Shemilt on 01.04.21.
//

import SwiftUI
import WidgetKit

struct SettingsView: View {
    @AppStorage(UserDefaultsKey.apiKeys, store: UserDefaults.shared) var keysData: Data?
    @State private var addKeySheet: Bool = false

    var apiKeys: [APIKey] {
        guard let data = keysData else { return [] }
        return APIKey.getKeysFromData(data) ?? []
    }

    var body: some View {
        Form {
            keySection

            Section {
                Button("Force Refresh Widget") {
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }

            contactSection
        }
        .navigationTitle("SETTINGS")
        .sheet(isPresented: $addKeySheet, content: sheet)
    }

    var keySection: some View {
        Section(header: Label("API_KEYS", systemImage: "key.fill"), footer: keySectionFooter) {
            ForEach(apiKeys) { key in
                NavigationLink(destination: APIKeyDetailView(key),
                               label: {
                                HStack {
                                    Text("\(Image(systemName: "circle.fill"))")
                                        .foregroundColor(key.color)
                                    Text(key.name)
                                    Spacer()
                                    if key.checkKey() == nil {
                                        Image(systemName: "checkmark.circle")
                                            .foregroundColor(.green)
                                    } else if key.checkKey() == .invalidCredentials {
                                        Image(systemName: "xmark.circle")
                                            .foregroundColor(.red)
                                    } else {
                                        Image(systemName: "exclamationmark.circle")
                                            .foregroundColor(.orange)
                                    }
                                }
                               })
            }
            .onDelete(perform: deleteKey)

            Button("ADD_KEY", action: { addKeySheet.toggle() })
        }
    }

    var keySectionFooter: some View {
        Text("\(Image(systemName: "checkmark.circle")): ")
            +
            Text("VALID_KEY")
            +
            Text(", \(Image(systemName: "xmark.circle")): ")
            +
            Text("INVALID_KEY")
            +
            Text(", \(Image(systemName: "exclamationmark.circle")): ")
            +
            Text("PROBLEM_KEY")
    }

    var contactSection: some View {
        Section(header: Label("Links", systemImage: "link")) {
            if let destination = URL(string: "https://github.com/mikakruschel/AppStore-Connect-Widget") {
                Link(destination: destination, label: {
                    Text("GitHub")
                })
            }

            if let destination = URL(string: "https://www.apple.com") {
                Link(destination: destination, label: {
                    Text("Buy me a coffee")
                })
            }
        }
    }

    private func sheet() -> some View {
        return OnboardingView(startAt: 1)
    }

    private func deleteKey(at offsets: IndexSet) {
        let keys = offsets.map({ apiKeys[$0] })
        APIKey.deleteApiKeys(apiKeys: keys)
        // TODO: show onboarding, when no keys are left
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}
