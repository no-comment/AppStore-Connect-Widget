//
//  ContentView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import AppStoreConnect_Swift_SDK

struct ContentView: View {
    @EnvironmentObject var apiKeysProvider: APIKeyProvider

    var completedOnboarding: Bool {
        return !apiKeysProvider.apiKeys.isEmpty
    }

    var body: some View {
        if completedOnboarding {
            NavigationView {
                HomeView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
        } else {
            OnboardingView(showsWelcome: true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
