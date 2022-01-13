//
//  OnboardingView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var apiKeysProvider: APIKeyProvider
    @State private var alert: AddAPIKeyAlert?
    @State private var page: OnboardingSection

    @State private var name: String = ""
    @State private var color: Color = .accentColor
    @State private var issuerID: String = ""
    @State private var keyID: String = ""
    @State private var key: String = ""
    @State private var vendor: String = ""

    @State private var errorFields: Set<Fields> = .init()

    init(showsWelcome: Bool) {
        self._page = State(initialValue: showsWelcome ? .welcome : .naming)
    }

    var body: some View {
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
        .navigationViewStyle(.stack)
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
        .padding()
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
                    .frame(maxWidth: 250, maxHeight: 30)
                Spacer()
                Button("NEXT", action: { page = .key })
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(name.isEmpty)
            }
            .padding()
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
                    FinishButton("FINISH", disabled: name.isEmpty || issuerID.isEmpty || keyID.isEmpty || key.isEmpty || vendor.isEmpty, successAction: onFinishPressed, failureAction: {
                        errorFields.removeAll()
                        if name.isEmpty { errorFields.insert(.name) }
                        if issuerID.isEmpty { errorFields.insert(.issuerID) }
                        if key.isEmpty { errorFields.insert(.key) }
                        if keyID.isEmpty { errorFields.insert(.keyID) }
                        if vendor.isEmpty { errorFields.insert(.vendor) }
                        if key.isEmpty { errorFields.insert(.key) }
                    })
                        .onChange(of: name + issuerID + keyID + key + vendor) { _ in errorFields.removeAll() }
                }
            }
            .padding()
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
                .modifier(TextFieldStyle(borderColor: errorFields.contains(.issuerID) ? .red : nil))

            infoCard(title: "WHERE_TO_FIND_ISSUER_ID_DESC", label: "WHERE_TO_FIND_ISSUER_ID")
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
                .modifier(TextFieldStyle(borderColor: errorFields.contains(.keyID) ? .red : nil))

            infoCard(title: "WHERE_TO_FIND_KEY_ID_DESC", label: "WHERE_TO_FIND_KEY_ID")
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
                    .modifier(TextFieldStyle(borderColor: errorFields.contains(.key) ? .red : nil))
                    .frame(height: 150)
            }

            infoCard(title: "WHERE_TO_FIND_KEY_DESC", label: "WHERE_TO_FIND_KEY")
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
                .modifier(TextFieldStyle(borderColor: errorFields.contains(.vendor) ? .red : nil))

            infoCard(title: "WHERE_TO_FIND_VENDOR_NR_DESC", label: "WHERE_TO_FIND_VENDOR_NR")
        }
    }

    private func onFinishPressed() {
        let apiKey = APIKey(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            color: color,
            issuerID: issuerID.trimmingCharacters(in: .whitespacesAndNewlines),
            privateKeyID: keyID.trimmingCharacters(in: .whitespacesAndNewlines),
            privateKey: key.trimmingCharacters(in: .whitespacesAndNewlines),
            vendorNumber: vendor.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        if apiKeysProvider.getApiKey(apiKeyId: apiKey.id) != nil {
            alert = .duplicateKey
            return
        }

        Task(priority: .userInitiated) {
            do {
                try await apiKey.checkKey()
                try apiKeysProvider.addApiKey(apiKey: apiKey)
                finishOnboarding()
                let api = AppStoreConnectApi(apiKey: apiKey)
                _ = try? await api.getData(useCache: true, useMemoization: false)
            } catch let err {
                let apiErr: APIError = (err as? APIError) ?? .unknown
                if apiErr == .invalidCredentials {
                    alert = .invalidKey
                }
            }
        }
    }

    private func finishOnboarding() {
        dismiss()
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

    func infoCard(title: LocalizedStringKey, label: LocalizedStringKey) -> some View {
        Card(innerPadding: 12) {
            DisclosureGroup(content: {
                Text(title).frame(maxWidth: .infinity, alignment: .leading)
            }, label: {
                Label(label, systemImage: "questionmark.circle")
            }).buttonStyle(.plain)
        }
    }

    private struct TextFieldStyle: ViewModifier {
        init(borderColor: Color? = nil, borderWidth: CGFloat = 1, cornerRadius: CGFloat = 5) {
            self.borderColor = borderColor ?? Color(UIColor.systemGray5)
            self.borderWidth = borderWidth
            self.cornerRadius = cornerRadius
        }

        let borderColor: Color
        let borderWidth: CGFloat
        let cornerRadius: CGFloat

        func body(content: Content) -> some View {
            content
                .buttonStyle(.plain)
                .padding(5)
                .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(borderColor, lineWidth: borderWidth))
                .disableAutocorrection(true)
                .font(.system(.body, design: .monospaced))
        }
    }

    enum Fields {
        case name, issuerID, keyID, key, vendor
    }
}

struct FinishButton: View {
    let title: LocalizedStringKey
    let disabled: Bool
    let successAction: () -> Void
    let failureAction: () -> Void

    init(_ title: LocalizedStringKey, disabled: Bool, successAction: @escaping () -> Void, failureAction: @escaping () -> Void) {
        self.title = title
        self.disabled = disabled
        self.successAction = successAction
        self.failureAction = failureAction
    }

    var body: some View {
        Button(title) {
            if disabled {
                failureAction()
            } else {
                successAction()
            }
        }
        .buttonStyle(PrimaryButtonStyle(color: disabled ? .secondary : .accentColor))
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
