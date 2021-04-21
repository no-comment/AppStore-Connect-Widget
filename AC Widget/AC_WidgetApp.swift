//
//  AC_WidgetApp.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import WidgetKit

@main
struct ACWidgetApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    WidgetCenter.shared.reloadAllTimelines()
                }
        }
    }
}
