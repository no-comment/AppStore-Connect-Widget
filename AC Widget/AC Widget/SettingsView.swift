//
//  SettingsView.swift
//  AC Widget
//
//  Created by Cameron Shemilt on 01.04.21.
//

import SwiftUI
import WidgetKit

struct SettingsView: View {
    @State var issuerID: String = UserDefaults.shared?.string(forKey: UserDefaultsKey.issuerID) ?? ""
    @State var privateKeyID: String = UserDefaults.shared?.string(forKey: UserDefaultsKey.privateKeyID) ?? ""
    @State var privateKey: String = UserDefaults.shared?.string(forKey: UserDefaultsKey.privateKey) ?? ""
    @State var vendorNumber: String = UserDefaults.shared?.string(forKey: UserDefaultsKey.vendorNumber) ?? ""
    
    var apiKeys: [APIKey] = [APIKey.example]
    
    var body: some View {
        Form {
            keySection
            
            saveSection
            
            contactSection
        }
        .onAppear {
            resetToUserDefaults()
        }
        .navigationTitle("SETTINGS")
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
            
            Button("ADD_KEY", action: {})
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
    
    var saveSection: some View {
        Section {
            Button("SAVE") {
                UserDefaults.shared?.setValue(issuerID, forKey: UserDefaultsKey.issuerID)
                UserDefaults.shared?.setValue(privateKeyID, forKey: UserDefaultsKey.privateKeyID)
                UserDefaults.shared?.setValue(privateKey, forKey: UserDefaultsKey.privateKey)
                UserDefaults.shared?.setValue(vendorNumber, forKey: UserDefaultsKey.vendorNumber)
                
                WidgetCenter.shared.reloadAllTimelines()
            }
            
            Button("CANCEL", action: resetToUserDefaults)
        }
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
    
    func resetToUserDefaults() {
        issuerID = UserDefaults.shared?.string(forKey: UserDefaultsKey.issuerID) ?? ""
        privateKeyID = UserDefaults.shared?.string(forKey: UserDefaultsKey.privateKeyID) ?? ""
        privateKey = UserDefaults.shared?.string(forKey: UserDefaultsKey.privateKey) ?? ""
        vendorNumber = UserDefaults.shared?.string(forKey: UserDefaultsKey.vendorNumber) ?? ""
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}
