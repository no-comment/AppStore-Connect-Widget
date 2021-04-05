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
    @State private var issuerID: String
    @State private var privateKeyID: String
    @State private var privateKey: String
    @State private var vendorNumber: String

    init(_ key: APIKey) {
        self.key = key
        self._keyName = State(initialValue: key.name)
        self._keyColor = State(initialValue: key.color)
        self._issuerID = State(initialValue: key.issuerID)
        self._privateKeyID = State(initialValue: key.privateKeyID)
        self._privateKey = State(initialValue: key.privateKey)
        self._vendorNumber = State(initialValue: key.privateKey)
    }

    var body: some View {
        Form {
            namingSection
            keySection
            savingSection
            statusSection
        }
        .navigationTitle(keyName)
    }

    var namingSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 0.0) {
                Text("KEY_NAME")
                    .bold()

                TextField("KEY_NAME", text: $keyName)
            }

            ColorPicker("KEY_COLOR", selection: $keyColor)
        }
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
    }

    var savingSection: some View {
        Section {
            Button("SAVE", action: save)
        }
    }

    private func save() {
        // TODO: Implement saving changes
    }

    var statusSection: some View {
        let status = key.checkKey()

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
