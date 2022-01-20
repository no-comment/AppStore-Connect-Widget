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
                }
        }
    }
}
