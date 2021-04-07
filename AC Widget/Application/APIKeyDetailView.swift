//
//  APIKeyDetailView.swift
//  AC Widget
//
//  Created by Cameron Shemilt on 04.04.21.
//

import SwiftUI

struct APIKeyDetailView: View {
    let key: APIKey
    @State private var keyName: String
    @State private var keyColor: Color
    private var issuerID: String
    private var privateKeyID: String
    private var privateKey: String
    private var vendorNumber: String

    @State private var status: APIError?

    init(_ key: APIKey) {
        self.key = key
        self._keyName = State(initialValue: key.name)
        self._keyColor = State(initialValue: key.color)
        self.issuerID = key.issuerID
        self.privateKeyID = key.privateKeyID
        self.privateKey = key.privateKey
        self.vendorNumber = key.vendorNumber
    }

    var body: some View {
        Form {
            namingSection
            keySection
            savingSection
            statusSection
        }
        .onAppear(perform: {
            key.checkKey().catch { err in
                status = (err as? APIError) ?? .unknown
            }
        })
        .navigationTitle(keyName)
    }

    var namingSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 0.0) {
                Text("KEY_NAME")
                    .bold()

                TextField("KEY_NAME", text: $keyName)
            }

            ColorPicker("KEY_COLOR", selection: $keyColor, supportsOpacity: false)
        }
    }

    var keySection: some View {
        Section(footer: Text("KEY_DETAIL_FOOTER")) {
            VStack(alignment: .leading, spacing: 0.0) {
                Text("ISSUER_ID")
                    .bold()

                TextField("ISSUER_ID", text: .constant(issuerID))
            }

            VStack(alignment: .leading, spacing: 0.0) {
                Text("PRIVATE_KEY_ID")
                    .bold()

                TextField("PRIVATE_KEY_ID", text: .constant(privateKeyID))
            }

            VStack(alignment: .leading, spacing: 0.0) {
                Text("PRIVATE_KEY")
                    .bold()

                TextEditor(text: .constant(privateKey))
            }

            VStack(alignment: .leading, spacing: 0.0) {
                Text("VENDOR_NR")
                    .bold()

                TextField("VENDOR_NR", text: .constant(vendorNumber))
            }
        }
    }

    var savingSection: some View {
        Section {
            Button("SAVE", action: save)
        }
    }

    private func save() {
        APIKey.addApiKey(apiKey: APIKey(name: keyName,
                                        color: keyColor,
                                        issuerID: issuerID,
                                        privateKeyID: privateKeyID,
                                        privateKey: privateKey,
                                        vendorNumber: vendorNumber))
    }

    var statusSection: some View {
        return Section {
            if let status = status {
                ErrorWidget(error: status)
            } else {
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
