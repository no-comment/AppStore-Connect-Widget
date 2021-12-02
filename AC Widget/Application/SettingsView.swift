//
//  SettingsView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import WidgetKit

struct SettingsView: View {
    @AppStorage(UserDefaultsKey.includeRedownloads, store: UserDefaults.shared) var includeRedownloads: Bool = false
    @AppStorage(UserDefaultsKey.appStoreNotice, store: UserDefaults.shared) var appStoreNotice: Bool = true
    @EnvironmentObject var apiKeysProvider: APIKeyProvider

    @State private var addKeySheet: Bool = false

    @State private var cachedEntries: Int = 0

    @State private var updateSheetVisible = false

    var body: some View {
        Form {
            keySection
            generalSection
            widgetSection
            storageSection
            contactSection
            versionSection
            notes
        }
        .navigationTitle("SETTINGS")
        .sheet(isPresented: $addKeySheet, content: sheet)
    }

    var keySection: some View {
        Section(header: Label("API_KEYS", systemImage: "key.fill"), footer: keySectionFooter) {
            ForEach(apiKeysProvider.apiKeys) { key in
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
        Text(" \(Image(systemName: "xmark.circle")): ")
        +
        Text("INVALID_KEY")
        +
        Text(" \(Image(systemName: "exclamationmark.circle")): ")
        +
        Text("PROBLEM_KEY")
    }

    var generalSection: some View {
        Section(header: Label("GENERAL", systemImage: "gearshape.fill")) {
            Toggle("INCLUDE_REDOWNLOADS", isOn: $includeRedownloads)
            NavigationLink("REARRANGE", destination: RearrangeTilesView())
            if AppStoreNotice.isTestFlight() {
                Toggle("APPSTORE_NOTICE_TOGGLE", isOn: $appStoreNotice)
            }
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
            Text("ALL_CACHED_ENTRIES:\(cachedEntries)")
                .onAppear {
                    self.cachedEntries = ACDataCache.numberOfEntriesCached()
                }

            Button("CLEAR_ALL_CACHE") {
                AppStoreConnectApi.clearInMemoryCache()
                APIKey.clearInMemoryCache()
                ACDataCache.clearCache()
                self.cachedEntries = ACDataCache.numberOfEntriesCached()
            }
            .foregroundColor(.orange)
        }
    }

    var contactSection: some View {
        Section(header: Label("Links", systemImage: "link")) {
            if let destination = URL(string: "https://github.com/no-comment/AppStore-Connect-Widget") {
                Link(destination: destination, label: {
                    HStack {
                        Label("GitHub", image: "logo.github")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.forward.app")
                    }
                }).contentShape(Rectangle())
            }

            if let destination = URL(string: "itms-apps://itunes.apple.com/app/id1562025981?mt=8&action=write-review") {
                Link(destination: destination, label: {
                    HStack {
                        Label("RATE_ACWIDGET", systemImage: "star")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.forward.app")
                    }.contentShape(Rectangle())
                })
            }

            if let destination = URL(string: "https://www.buymeacoffee.com/nocomment") {
                Link(destination: destination, label: {
                    HStack {
                        Label("Buy me a Coffee", image: "logo.buymeacoffee")
                            .symbolRenderingMode(.multicolor)
                        Spacer()
                        Image(systemName: "arrow.up.forward.app")
                    }.contentShape(Rectangle())
                })
            }
        }
        .buttonStyle(.plain)
    }

    var versionSection: some View {
        Section {
            HStack {
                Image(systemName: "info.circle").frame(width: 25)
                Text("VERSION")
                Spacer()
                Text(verbatim: UIApplication.appVersion ?? "")
            }
            .contentShape(Rectangle())
            .onTapGesture {
                updateSheetVisible.toggle()
            }
            .sheet(isPresented: $updateSheetVisible) {
                UpdateView()
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
        let keys = offsets.map({ apiKeysProvider.apiKeys[$0] })
        keys.forEach { ACDataCache.clearCache(apiKey: $0) }
        apiKeysProvider.deleteApiKeys(keys: keys)
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
            Task(priority: .background) {
                do {
                    try await key.checkKey()
                } catch let err {
                    status = (err as? APIError) ?? .unknown
                }
                loading = false
            }
        })
    }
}
