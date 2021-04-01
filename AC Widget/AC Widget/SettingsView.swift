//
//  SettingsView.swift
//  AC Widget
//
//  Created by Cameron Shemilt on 01.04.21.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("issuerID") var issuerID = ""
    @AppStorage("keyID") var keyID = ""
    @AppStorage("apiKey") var apiKey = ""
    @AppStorage("vendorNr") var vendorNr = ""
    
    var body: some View {
        Form {
            keySection
            contactSection
        }
        .navigationTitle("Settings")
    }
    
    var keySection: some View {
        Section(header: Label("API Key", systemImage: "key.fill")) {
            VStack(alignment: .leading) {
                Text("Issuer ID")
                    .bold()
                
                TextField("Issuer ID", text: $issuerID)
            }
            
            VStack(alignment: .leading) {
                Text("Key ID")
                    .bold()
                
                TextField("Key ID", text: $keyID)
            }
            
            VStack(alignment: .leading) {
                Text("Key")
                    .bold()
                
                TextEditor(text: $apiKey)
            }
            
            VStack(alignment: .leading) {
                Text("Vendor Nr.")
                    .bold()
                
                TextField("Vendor Nr.", text: $vendorNr)
            }
        }
    }
    
    var contactSection: some View {
        Section(header: Label("Development", systemImage: "hammer.fill")) {
            Button(action: {}, label: {
                Text("GitHub")
            })
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}
