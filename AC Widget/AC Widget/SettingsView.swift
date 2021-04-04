//
//  SettingsView.swift
//  AC Widget
//
//  Created by Cameron Shemilt on 01.04.21.
//

import SwiftUI
import WidgetKit

struct SettingsView: View {
    var apiKeys: [APIKey] = [APIKey.example]
    @State private var addKeySheet: Bool = false
    
    var body: some View {
        Form {
            keySection
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
            Link(destination: URL(string: "https://github.com/mikakruschel/AppStore-Connect-Widget")!, label: {
                Text("GitHub")
            })
            
            Link(destination: URL(string: "https://www.apple.com")!, label: {
                Text("Buy me a coffee")
            })
        }
    }
    
    private func sheet() -> some View {
        return OnboardingView(startAt: 1)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}
