//
//  OnboardingView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var alert: AddAPIKeyAlert?

    private let showsWelcome: Bool

    @State private var name: String = ""
    @State private var color: Color = .accentColor
    @State private var issuerID: String = ""
    @State private var keyID: String = ""
    @State private var key: String = ""
    @State private var vendor: String = ""

    init(showsWelcome: Bool = true) {
        self.showsWelcome = showsWelcome
        UITextView.appearance().backgroundColor = .red
    }

    var body: some View {
        ScrollView {
            if showsWelcome {
                GroupBox(label: Text("WELCOME"), content: {
                    welcomeSection
                })
                .padding()
            }

            GroupBox(label: Text("KEY_NAME"), content: {
                nameSection
            })
            .padding()

            GroupBox(label: Text("ISSUER_ID"), content: {
                issuerIDSection
            })
            .padding()

            GroupBox(label: Text("PRIVATE_KEY_ID"), content: {
                privateKeyIDSection
            })
            .padding()

            GroupBox(label: Text("PRIVATE_KEY"), content: {
                privateKeySection
            })
            .padding()

            GroupBox(label: Text("VENDOR_NR"), content: {
                VendorNrSection
            })
            .padding()

            finishButton
                .padding()
        }
        .multilineTextAlignment(.center)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .alert(item: $alert, content: { generateAlert($0) })
    }

    // MARK: Pages
    var welcomeSection: some View {
        VStack(spacing: 20) {
            SummaryMedium(data: ACData.example, color: color)
                .showAsWidget(.systemMedium)
                .padding(.top)

            Text("ONBOARD_WELCOME")
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    var nameSection: some View {
        VStack(spacing: 20) {
            TextField("KEY_NAME", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Text("ONBOARD_KEY_NAME")
                .fixedSize(horizontal: false, vertical: true)
            Divider()
            Text("ONBOARD_KEY_COLOR")
                .fixedSize(horizontal: false, vertical: true)

            ColorPicker(selection: $color, supportsOpacity: false, label: {
                Text("KEY_COLOR")
                    .fixedSize()
            })
            .frame(maxWidth: 250)
        }
    }

    var issuerIDSection: some View {
        VStack(spacing: 20) {
            TextField("ISSUER_ID", text: $issuerID)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)

            Text("ONBOARD_ISSUER_ID")
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    var privateKeyIDSection: some View {
        VStack(spacing: 20) {
            TextField("PRIVATE_KEY_ID", text: $keyID)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)

            Text("ONBOARD_PRIVATE_KEY_ID")
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    var privateKeySection: some View {
        VStack(spacing: 20) {
            TextEditor(text: $key)
                .frame(maxHeight: 250)
                .disableAutocorrection(true)
                .background(Color.systemWhite.cornerRadius(5))
                .overlay(
                    RoundedRectangle(cornerRadius: 5).stroke(Color(.systemGray4), lineWidth: 0.3)
                )

            Text("ONBOARD_PRIVATE_KEY")
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    var VendorNrSection: some View {
        VStack(spacing: 20) {
            TextField("VENDOR_NR", text: $vendor)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)

            Text("ONBOARD_VENDOR_NR")
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: Finish Button
    var finishButton: some View {
        Button(action: onFinishPressed, label: {
            Text("FINISH")
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .foregroundColor(.white)
                .background(Color.accentColor)
                .clipShape(Capsule())
                .contentShape(Rectangle())
        })
        .disabled(
            name.isEmpty || issuerID.isEmpty || keyID.isEmpty || key.isEmpty || vendor.isEmpty
        )
    }

    private func onFinishPressed() {
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
            button = Alert.Button.default(Text("OK"))
        case .duplicateKey:
            title = Text("DUPLICATE_KEY")
            message = Text("DUPLICATE_KEY_MSG")
            button = Alert.Button.default(Text("RECHECK_INPUTS"))
        }
        return Alert(title: title, message: message, dismissButton: button)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
