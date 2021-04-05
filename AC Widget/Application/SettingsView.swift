//
//  SettingsView.swift
//  AC Widget
//
//  Created by Cameron Shemilt on 01.04.21.
//

import SwiftUI
import WidgetKit

struct SettingsView: View {
    var apiKeys: [APIKey] { APIKey.getApiKeys() }
    @State private var addKeySheet: Bool = false

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
        offsets.forEach {
            APIKey.deleteApiKey(apiKey: apiKeys[$0])
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}
