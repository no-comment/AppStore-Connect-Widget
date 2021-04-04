//
//  APIKeyDetailView.swift
//  AC Widget
//
//  Created by Cameron Shemilt on 04.04.21.
//

import SwiftUI

struct APIKeyDetailView: View {
    let key: APIKey
    @State var issuerID: String
    @State var privateKeyID: String
    @State var privateKey: String
    @State var vendorNumber: String
    
    init(_ key: APIKey) {
        self.key = key
        self._issuerID = State(initialValue: key.issuerID)
        self._privateKeyID = State(initialValue: key.privateKeyID)
        self._privateKey = State(initialValue: key.privateKey)
        self._vendorNumber = State(initialValue: key.privateKey)
    }
    
    var body: some View {
        Form {
            keySection
            statusSection
        }
        .navigationTitle(key.name)
    }
    
    var keySection: some View {
        Section {
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
        .disabled(true)
    }
    
    var statusSection: some View {
        let status = key.checkKey()
        
        return Section {
            if status == nil {
            } else {
                ErrorWidget(error: status!)
            }
        }
        .frame(maxHeight: 250)
    }
}

struct APIKeyDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            APIKeyDetailView(APIKey.example)
        }
    }
}
