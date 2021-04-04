//
//  ContentView.swift
//  AC Widget
//
//  Created by Miká Kruschel on 29.03.21.
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
