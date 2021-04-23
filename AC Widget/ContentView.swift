//
//  ContentView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import AppStoreConnect_Swift_SDK

struct ContentView: View {
    @AppStorage(UserDefaultsKey.completedOnboarding) var completedOnboarding: Bool = false

    var body: some View {
        if completedOnboarding {
            NavigationView {
                HomeView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
        } else {
            OnboardingView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
