//
//  ContentView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import AppStoreConnect_Swift_SDK

struct ContentView: View {
    @AppStorage(UserDefaultsKey.apiKeys, store: UserDefaults.shared) var keysData: Data?

    var completedOnboarding: Bool {
        guard let data = keysData, let keys = APIKey.getKeysFromData(data) else { return false }
        return !keys.isEmpty
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
