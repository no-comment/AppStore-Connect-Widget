//
//  AC_WidgetApp.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import WidgetKit

@main
struct ACWidgetApp: App {
    @StateObject private var apiKeysProvider = APIKeyProvider()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(apiKeysProvider)
                .onAppear {
                    WidgetCenter.shared.reloadAllTimelines()

                    // Migrate api keys from UserDefaults to Keychain
                    guard let keyData: Data = UserDefaults.shared?.data(forKey: UserDefaultsKey.apiKeys) else { return }
                    let decoder = JSONDecoder()
                    let keys = try? decoder.decode([APIKey].self, from: keyData)
                    for key in keys ?? [] {
                        try? apiKeysProvider.addApiKey(apiKey: key)
                    }
                    UserDefaults.shared?.removeObject(forKey: UserDefaultsKey.apiKeys)
                }
        }
    }
}
