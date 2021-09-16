//
//  OnboardingView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var alert: AddAPIKeyAlert?

    let showsWelcome: Bool

    @State private var name: String = ""
    @State private var color: Color = .accentColor
    @State private var issuerID: String = ""
    @State private var keyID: String = ""
    @State private var key: String = ""
    @State private var vendor: String = ""

    init(showsWelcome: Bool) {
        self.showsWelcome = showsWelcome
        UITextView.appearance().backgroundColor = .clear
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 330))], alignment: .center, spacing: 20) {
                if showsWelcome {
                    welcomeSection.padding(.horizontal, 5)
                }

                nameSection.padding(.horizontal, 5)

                issuerIDSection.padding(.horizontal, 5)

                privateKeyIDSection.padding(.horizontal, 5)

                privateKeySection.padding(.horizontal, 5)

                VendorNrSection.padding(.horizontal, 5)
            }
            .padding()

            finishButton
                .padding(.bottom)
        }
        .alert(item: $alert, content: { generateAlert($0) })
    }

    // MARK: Pages
    var welcomeSection: some View {
        GroupBox(label: Text("WELCOME"), content: {
            SummaryMedium(data: ACData.example, color: color, filteredApps: [])
                .showAsWidget(.systemMedium)
                .padding(.vertical)

            Text("ONBOARD_WELCOME")
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
            Spacer()
        })
    }

    var nameSection: some View {
        GroupBox(label: Text("KEY_NAME"), content: {
            TextField("KEY_NAME", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Text("ONBOARD_KEY_NAME")
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
            Divider()
            Spacer()

            Text("ONBOARD_KEY_COLOR")
                .fixedSize(horizontal: false, vertical: true)

            ColorPicker(selection: $color, supportsOpacity: false, label: {
                Text("KEY_COLOR")
                    .fixedSize()
            })
                .frame(maxWidth: 250, maxHeight: 30)
            Spacer()
        })
    }

    var issuerIDSection: some View {
        GroupBox(label: Text("ISSUER_ID"), content: {
            TextField("ISSUER_ID", text: $issuerID)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)

            Text("ONBOARD_ISSUER_ID")
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        })
    }

    var privateKeyIDSection: some View {
        GroupBox(label: Text("PRIVATE_KEY_ID"), content: {
            TextField("PRIVATE_KEY_ID", text: $keyID)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)

            Text("ONBOARD_PRIVATE_KEY_ID")
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        })
    }

    var privateKeySection: some View {
        GroupBox(label: Text("PRIVATE_KEY"), content: {
            TextEditor(text: $key)
                .frame(minHeight: 30, maxHeight: 250)
                .disableAutocorrection(true)
                .background(Color.systemWhite.cornerRadius(5))
                .overlay(
                    RoundedRectangle(cornerRadius: 5).stroke(Color(.systemGray4), lineWidth: 0.3)
                )

            Text("ONBOARD_PRIVATE_KEY")
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        })
    }

    var VendorNrSection: some View {
        GroupBox(label: Text("VENDOR_NR"), content: {
            TextField("VENDOR_NR", text: $vendor)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)

            Text("ONBOARD_VENDOR_NR")
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        })
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
        OnboardingView(showsWelcome: true)
    }
}
