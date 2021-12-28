//
//  OnboardingView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

// swiftlint:disable type_body_length
struct OnboardingView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var apiKeysProvider: APIKeyProvider
    @State private var alert: AddAPIKeyAlert?
    @State private var page: OnboardingSection

    @State private var name: String = ""
    @State private var color: Color = .accentColor
    @State private var issuerID: String = ""
    @State private var keyID: String = ""
    @State private var key: String = ""
    @State private var vendor: String = ""

    init(showsWelcome: Bool) {
        self._page = State(initialValue: showsWelcome ? .welcome : .naming)
    }

    var body: some View {
        NavigationView {
            Group {
                switch page {
                case .welcome:
                    welcomeSection
                case .naming:
                    nameSection
                case .key:
                    creatingKeySection
                }
            }
            .tabViewStyle(.page)
            .navigationTitle(page == .welcome ? "" : "ADD_KEY")
            .navigationBarTitleDisplayMode(.inline)
            .alert(item: $alert, content: { generateAlert($0) })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: Pages
    var welcomeSection: some View {
        VStack {
            Text("WELCOME_TO")
                .padding(.top, 50)
                .foregroundColor(.gray)
            Text("ACWidget")
                .font(.system(size: 45, weight: .semibold, design: .rounded))
                .foregroundColor(.accentColor)

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    UpdateDetailView(imageName: "logo.github", title: "OPEN_SOURCE", subTitle: "OPEN_SOURCE_DESCRIPTION")
                    UpdateDetailView(systemName: "key.fill", title: "MULTIPLE_KEYS", subTitle: "MULTIPLE_KEYS_DESCRIPTION")
                    UpdateDetailView(systemName: "eurosign.circle", title: "ALL_CURRENCIES", subTitle: "ALL_CURRENCIES_DESCRIPTION")
                    UpdateDetailView(systemName: "rectangle.3.group", title: "ALL_WIDGET_SIZES", subTitle: "ALL_WIDGET_SIZES_DESCRIPTION")
                }
                .padding(.horizontal)
            }

            Button("START", action: { page = .naming })
                .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.horizontal)
    }

    var nameSection: some View {
            VStack(spacing: 25) {
                Image(systemName: "person.fill.badge.plus")
                    .renderingMode(.original)
                    .foregroundColor(.accentColor)
                    .font(.system(size: 45, weight: .medium))
                    .padding(.top, 35)

                Text("ONBOARD_KEY_NAME")

                TextField("KEY_NAME", text: $name)
                    .textFieldStyle(.roundedBorder)

                Text("ONBOARD_KEY_COLOR")

                ColorPicker(selection: $color, supportsOpacity: false, label: {
                    Text("KEY_COLOR")
                        .fixedSize()
                })
                Spacer()
                Button("NEXT", action: { page = .key })
                    .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.horizontal)
    }

    var creatingKeySection: some View {
        ScrollView {
            VStack(spacing: 25) {
                HStack(alignment: .top, spacing: 2) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 45, weight: .medium))
                        .foregroundColor(.accentColor)
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 25, weight: .medium))
                        .foregroundColor(.green)
                }
                .padding(.top, 35)

                Text("CREATE_KEY_NOTICE")
                    .multilineTextAlignment(.center)

                // swiftlint:disable force_unwrapping
                Link(destination: URL(string: "https://developer.apple.com/documentation/appstoreconnectapi/creating_api_keys_for_app_store_connect_api")!) {
                    Card(innerPadding: 12) {
                        HStack {
                            Label("HOW_TO_CREATE_APIKEY", systemImage: "questionmark.circle")
                            Spacer()
                            Image(systemName: "arrow.up.forward.app")
                        }
                    }
                }
                .buttonStyle(.plain)

                issuerIDSection
                privateKeyIDSection
                privateKeySection
                vendorNrSection

                HStack {
                    Button(action: { page = .naming }, label: { Image(systemName: "chevron.left") })
                        .buttonStyle(PrimarySquareButtonStyle(color: .cardColor, foregroundColor: .accentColor))
                    Button("FINISH", action: onFinishPressed)
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(
                            name.isEmpty || issuerID.isEmpty || keyID.isEmpty || key.isEmpty || vendor.isEmpty
                        )
                }
            }
            .padding(.horizontal)
        }
    }

    var issuerIDSection: some View {
        VStack {
            HStack {
                Image(systemName: "person.text.rectangle.fill")
                    .foregroundColor(.green)
                Text("ISSUER_ID")
                Spacer()
            }
            .font(.system(size: 20, weight: .medium, design: .rounded))

            TextField("XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX", text: $issuerID)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)
                .font(.system(.body, design: .monospaced))

            Card(innerPadding: 12) {
                DisclosureGroup(content: {
                    Text("WHERE_TO_FIND_ISSUER_ID_DESC")
                }, label: { Label("WHERE_TO_FIND_ISSUER_ID", systemImage: "questionmark.circle") })
                    .buttonStyle(.plain)
            }
        }
    }

    var privateKeyIDSection: some View {
        VStack {
            HStack {
                Image(systemName: "grid.circle.fill")
                    .foregroundColor(.green)
                Text("PRIVATE_KEY_ID")
                Spacer()
            }
            .font(.system(size: 20, weight: .medium, design: .rounded))

            TextField("XXXXXXXXXX", text: $keyID)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)
                .font(.system(.body, design: .monospaced))

            Card(innerPadding: 12) {
                DisclosureGroup(content: {
                    Text("WHERE_TO_FIND_KEY_ID_DESC")
                }, label: { Label("WHERE_TO_FIND_KEY_ID", systemImage: "questionmark.circle") })
                    .buttonStyle(.plain)
            }
        }
    }

    var privateKeySection: some View {
        VStack {
            HStack {
                Image(systemName: "key.fill")
                    .foregroundColor(.green)
                Text("PRIVATE_KEY")
                Spacer()
            }
            .font(.system(size: 20, weight: .medium, design: .rounded))

            VStack {
                TextEditor(text: $key)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
                    .frame(height: 150)
                    .font(.system(.body, design: .monospaced))
            }
            .overlay(
                     RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                     )

            Card(innerPadding: 12) {
                DisclosureGroup(content: {
                    Text("WHERE_TO_FIND_KEY_DESC")
                }, label: { Label("WHERE_TO_FIND_KEY", systemImage: "questionmark.circle") })
                    .buttonStyle(.plain)
            }
        }
    }

    var vendorNrSection: some View {
        VStack {
            HStack {
                Image(systemName: "cart.fill")
                    .foregroundColor(.green)
                Text("VENDOR_NR")
                Spacer()
            }
            .font(.system(size: 20, weight: .medium, design: .rounded))

            TextField("XXXXXXXX", text: $vendor)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)
                .font(.system(.body, design: .monospaced))

            Card(innerPadding: 12) {
                DisclosureGroup(content: {
                    Text("WHERE_TO_FIND_VENDOR_NR_DESC")
                }, label: { Label("WHERE_TO_FIND_VENDOR_NR", systemImage: "questionmark.circle") })
                    .buttonStyle(.plain)
            }
        }
    }

    private func onFinishPressed() {
        let apiKey = APIKey(name: name, color: color, issuerID: issuerID, privateKeyID: keyID, privateKey: key, vendorNumber: vendor)

        if apiKeysProvider.getApiKey(apiKeyId: apiKey.id) != nil {
            alert = .duplicateKey
            return
        }

        Task(priority: .userInitiated) {
            do {
                try await apiKey.checkKey()
                try apiKeysProvider.addApiKey(apiKey: apiKey)
                finishOnboarding()
            } catch let err {
                let apiErr: APIError = (err as? APIError) ?? .unknown
                if apiErr == .invalidCredentials {
                    alert = .invalidKey
                }
            }
        }
    }

    private func finishOnboarding() {
        presentationMode.wrappedValue.dismiss()
    }

    private enum OnboardingSection: Int, Identifiable {
        case welcome = 0
        case naming = 1
        case key = 2

        var id: Int { self.rawValue }
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
        Group {
            OnboardingView(showsWelcome: true)
            OnboardingView(showsWelcome: true)
                .preferredColorScheme(.dark)
        }
    }
}
