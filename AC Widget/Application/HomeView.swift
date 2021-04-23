//
//  HomeView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import AppStoreConnect_Swift_SDK

struct HomeView: View {
    @State var data: ACData?
    @State var error: APIError?
    @State var showingSheet: Bool = false

    @AppStorage(UserDefaultsKey.homeSelectedKey, store: UserDefaults.shared) private var keyID: String = ""
    @AppStorage(UserDefaultsKey.homeCurrency, store: UserDefaults.shared) private var currency: String = "USD"
    private var selectedKey: APIKey? {
        return APIKey.getApiKey(apiKeyId: keyID) ?? APIKey.getApiKeys().first
    }

    var body: some View {
        ScrollView {
            if let data = data {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 320))], spacing: 8) {
                    InfoTile(description: "DOWNLOADS", data: data, type: .downloads)
                    InfoTile(description: "PROCEEDS", data: data, type: .proceeds)
                    InfoTile(description: "UPDATES", data: data, type: .updates)
                }
                .padding(.horizontal)
            } else {
                loadingIndicator
            }
            additionalInformation
        }
        .navigationTitle("HOME")
        .toolbar(content: toolbar)
        .sheet(isPresented: $showingSheet, content: sheet)
        .onChange(of: keyID, perform: { _ in onAppear() })
        .onChange(of: currency, perform: { _ in onAppear() })
        .onAppear(perform: { onAppear() })
    }

    var loadingIndicator: some View {
        HStack(spacing: 10) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())

            Text("LOADING_DATA")
                .foregroundColor(.gray)
                .italic()
        }
        .padding(.top, 25)
    }

    var additionalInformation: some View {
        VStack(spacing: 20) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 8) {
                Text("LAST_CHANGE:\(data?.latestReportingDate() ?? "-")")
                    .font(.system(size: 12))
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("CURRENCY:\(data?.displayCurrency.rawValue ?? "-")")
                    .font(.system(size: 12))
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("API_KEY:\(APIKey.getApiKey(apiKeyId: keyID)?.name ?? "-")")
                    .font(.system(size: 12))
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button("REFRESH_DATA", action: { onAppear(useCache: false) })
                .padding(.vertical, 8)
                .padding(.horizontal, 20)
                .background(Color.cardColor)
                .clipShape(Capsule())
                .foregroundColor(.primary)
        }
        .foregroundColor(.gray)
        .padding()
    }

    func toolbar() -> some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { showingSheet.toggle() }, label: {
                    Image(systemName: "key")
                })
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView(),
                               label: { Image(systemName: "gear") }
                )
            }
        }
    }

    func sheet() -> some View {
        NavigationView {
            KeySelectionView()
                .toolbar {
                    ToolbarItem {
                        Button("DONE", action: { showingSheet = false })
                    }
                }
        }
    }

    private func onAppear(useCache: Bool = true) {
        guard let apiKey = selectedKey else { return }
        let api = AppStoreConnectApi(apiKey: apiKey)
        api.getData(currency: Currency(rawValue: currency), useCache: useCache).then { (data) in
            self.data = data
        }.catch { (err) in
            guard let apiErr = err as? APIError else {
                return
            }
            self.error = apiErr
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                HomeView(data: ACData.example)
            }

            NavigationView {
                HomeView(data: ACData.example)
            }
            .preferredColorScheme(.dark)
        }
    }
}
