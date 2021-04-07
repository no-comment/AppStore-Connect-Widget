//
//  OnboardingView.swift
//  AC Widget
//
//  Created by Cameron Shemilt on 03.04.21.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selection: Int
    @State private var alert: AddAPIKeyAlert?

    @State private var name: String = ""
    @State private var color: Color = .accentColor
    @State private var issuerID: String = ""
    @State private var keyID: String = ""
    @State private var key: String = ""
    @State private var vendor: String = ""

    init(startAt: Int = 0) {
        self._selection = State(initialValue: startAt)
    }

    var body: some View {
        TabView(selection: $selection) {
            welcomeSection
                .padding()
                .tag(0)

            nameSection
                .padding()
                .tag(1)

            issuerIDSection
                .padding()
                .tag(2)

            privateKeyIDSection
                .padding()
                .tag(3)

            privateKeySection
                .padding()
                .tag(4)

            VendorNrSection
                .padding()
                .tag(5)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .alert(item: $alert, content: { generateAlert($0) })
    }

    // MARK: Pages
    var welcomeSection: some View {
        VStack(spacing: 20) {
            Text("WELCOME")
                .font(.system(.largeTitle, design: .rounded))

            SummaryMedium(data: ACData.example)
                .showAsWidget(.systemMedium)

            Text("ONBOARD_WELCOME")

            Spacer()
            nextButton
        }
    }

    var nameSection: some View {
        VStack(spacing: 20) {
            Text("KEY_NAME")
                .font(.system(.largeTitle, design: .rounded))

            TextField("KEY_NAME", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Text("ONBOARD_KEY_NAME")

            Text("ONBOARD_KEY_COLOR")

            ColorPicker("KEY_COLOR", selection: $color)

            Spacer()
            nextButton
                .disabled(name.isEmpty)
        }
    }

    var issuerIDSection: some View {
        VStack(spacing: 20) {
            Text("ISSUER_ID")
                .font(.system(.largeTitle, design: .rounded))

            TextField("ISSUER_ID", text: $issuerID)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)

            Text("ONBOARD_ISSUER_ID")

            Spacer()
            nextButton
                .disabled(issuerID.isEmpty)
        }
    }

    var privateKeyIDSection: some View {
        VStack(spacing: 20) {
            Text("PRIVATE_KEY_ID")
                .font(.system(.largeTitle, design: .rounded))

            TextField("PRIVATE_KEY_ID", text: $keyID)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)

            Text("ONBOARD_PRIVATE_KEY_ID")

            Spacer()
            nextButton
                .disabled(keyID.isEmpty)
        }
    }

    var privateKeySection: some View {
        VStack(spacing: 20) {
            Text("PRIVATE_KEY")
                .font(.system(.largeTitle, design: .rounded))

            TextEditor(text: $key)
                .frame(maxHeight: 250)
                .border(Color.gray)
                .disableAutocorrection(true)

            Text("ONBOARD_PRIVATE_KEY")

            Spacer()
            nextButton
                .disabled(key.isEmpty)
        }
    }

    var VendorNrSection: some View {
        VStack(spacing: 20) {
            Text("VENDOR_NR")
                .font(.system(.largeTitle, design: .rounded))

            TextField("VENDOR_NR", text: $vendor)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)

            Text("ONBOARD_VENDOR_NR")

            Spacer()
            nextButton
                .disabled(vendor.isEmpty)
        }
    }

    // MARK: Next Button
    var nextButton: some View {
        Button(action: onNextPress, label: {
            Text(selection < 5 ? "NEXT" : "FINISH")
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .foregroundColor(.white)
                .background(Color.accentColor)
                .clipShape(Capsule())
                .contentShape(Rectangle())
        })
    }

    private func onNextPress() {
        if selection < 5 {
            selection += 1
        } else {
            let apiKey = APIKey(name: name, color: color, issuerID: issuerID, privateKeyID: keyID, privateKey: key, vendorNumber: vendor)

            if APIKey.getApiKeys().contains(where: { $0.id == apiKey.id }) {
                alert = .duplicateKey
                return
            }

            apiKey.checkKey()
                .then {
                    APIKey.addApiKey(apiKey: apiKey)
                    finishOnboarding()
                }
                .catch { err in
                    let apiErr: APIError = (err as? APIError) ?? .unknown
                    if apiErr == .invalidCredentials {
                        alert = .invalidKey
                    }
                }
        }
    }

    private func finishOnboarding() {
        UserDefaults.standard.set(true, forKey: UserDefaultsKey.completedOnboarding)
        presentationMode.wrappedValue.dismiss()
    }

    // MARK: Alert
    private enum AddAPIKeyAlert: Int, Identifiable {
        case invalidKey = 0
        case duplicateKey = 1

        var id: Int { self.rawValue }
    }

    private func generateAlert(_ alertType: AddAPIKeyAlert) -> Alert {
        let button: Alert.Button
        let title: Text
        let message: Text
        switch alertType {
        case .invalidKey:
            title = Text("INVALID_KEY")
            message = Text("INVALID_KEY_MSG")
            button = Alert.Button.default(Text("OK"), action: { self.selection = 1 })
        case .duplicateKey:
            title = Text("DUPLICATE_KEY")
            message = Text("DUPLICATE_KEY_MSG")
            button = Alert.Button.default(Text("RECHECK_INPUTS"), action: { self.selection = 1 })
        }
        return Alert(title: title, message: message, dismissButton: button)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
