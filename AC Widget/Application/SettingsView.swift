//
//  SettingsView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import WidgetKit

struct SettingsView: View {
    @AppStorage(UserDefaultsKey.apiKeys, store: UserDefaults.shared) var keysData: Data?
    @AppStorage(UserDefaultsKey.includeRedownloads, store: UserDefaults.shared) var includeRedownloads: Bool = false
    @State private var addKeySheet: Bool = false

    var apiKeys: [APIKey] {
        guard let data = keysData else { return [] }
        return APIKey.getKeysFromData(data) ?? []
    }

    var body: some View {
        Form {
            keySection
            generalSection
            widgetSection
            storageSection
            contactSection
            notes
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
                                    ApiKeyCheckIndicator(key: key)
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

    var generalSection: some View {
        Section(header: Label("GENERAL", systemImage: "gearshape.fill")) {
            Toggle("INCLUDE_REDOWNLOADS", isOn: $includeRedownloads)
            NavigationLink("REARRANGE", destination: RearrangeTilesView())
        }
    }

    var widgetSection: some View {
        Section(header: Label("WIDGET", systemImage: "rectangle.3.offgrid.fill")) {
            Button("FORCE_REFRESH_WIDGET") {
                AppStoreConnectApi.clearInMemoryCache()
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }

    var storageSection: some View {
        Section(header: Label("STORAGE", systemImage: "externaldrive.fill")) {
            Text("ALL_CACHED_ENTRIES:\(ACDataCache.numberOfEntriesCached())")

            Button("CLEAR_ALL_CACHE") {
                AppStoreConnectApi.clearInMemoryCache()
                APIKey.clearInMemoryCache()
                ACDataCache.clearCache()
            }
            .foregroundColor(.orange)
        }
    }

    var contactSection: some View {
        Section(header: Label("Links", systemImage: "link")) {
            if let destination = URL(string: "https://github.com/no-comment/AppStore-Connect-Widget") {
                Link(destination: destination, label: {
                    Text("GitHub")
                })
            }

            if let destination = URL(string: "https://www.buymeacoffee.com/nocomment") {
                Link(destination: destination, label: {
                    Text("Buy me a coffee")
                })
            }
        }
    }

    var notes: some View {
        Section(footer: Text("UPDATE_FREQUENCY_NOTICE")) {
            EmptyView()
        }
    }

    private func sheet() -> some View {
        return NavigationView {
            OnboardingView(showsWelcome: false)
                .navigationTitle("ADD_KEY")
                .navigationBarTitleDisplayMode(.inline)
                .closeSheetButton()
        }
    }

    private func deleteKey(at offsets: IndexSet) {
        let keys = offsets.map({ apiKeys[$0] })
        keys.forEach { ACDataCache.clearCache(apiKey: $0) }
        APIKey.deleteApiKeys(apiKeys: keys)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}

// MARK: - ApiKeyCheckIndicator

struct ApiKeyCheckIndicator: View {
    let key: APIKey
    @State var status: APIError?
    @State var loading = true

    var body: some View {
        Group {
            if loading {
                Image(systemName: "circle")
                    .foregroundColor(.gray)
            } else if status == nil {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
            } else if status == .invalidCredentials {
                Image(systemName: "xmark.circle")
                    .foregroundColor(.red)
            } else {
                Image(systemName: "exclamationmark.circle")
                    .foregroundColor(.orange)
            }
        }
        .onAppear(perform: {
            key.checkKey()
                .catch { err in
                    status = (err as? APIError) ?? .unknown
                }
                .always {
                    loading = false
                }
        })
    }
}
