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
        Section(header: Label("API_KEY", systemImage: "key.fill")) {
            VStack(alignment: .leading, spacing: 0.0) {
                Text("ISSUER_ID")
                    .bold()
                
                TextField("ISSUER_ID", text: $issuerID)
            }
            
            VStack(alignment: .leading, spacing: 0.0) {
                Text("PRIVATE_KEY_ID")
                    .bold()
                
                TextField("PRIVATE_KEY_ID", text: $privateKeyID)
            }
            
            VStack(alignment: .leading, spacing: 0.0) {
                Text("PRIVATE_KEY")
                    .bold()
                ZStack {
                    TextEditor(text: $privateKey)
                    if privateKey.isEmpty {
                        VStack {
                            HStack {
                                Text("PRIVATE_KEY")
                                    .foregroundColor(Color(UIColor.placeholderText))
                                Spacer()
                            }
                        }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 0.0) {
                Text("VENDOR_NR")
                    .bold()
                
                TextField("VENDOR_NR", text: $vendorNumber)
            }
        }
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
        Section(header: Label("Development", systemImage: "hammer.fill")) {
            Button(action: {}, label: {
                Text("GitHub")
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
