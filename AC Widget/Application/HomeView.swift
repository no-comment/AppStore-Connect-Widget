//
//  HomeView.swift
//  AC Widget
//
//  Created by Cameron Shemilt on 03.04.21.
//

import SwiftUI
import AppStoreConnect_Swift_SDK

struct HomeView: View {
    @State var data: ACData?
    @State var error: APIError?

    var body: some View {
        ScrollView {
            if let data = data {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 320))], spacing: 8) {
                    InfoTile(description: "DOWNLOADS", data: data, type: .downloads)
                    InfoTile(description: "PROCEEDS", data: data, type: .proceeds)
                    InfoTile(description: "UPDATES", data: data, type: .updates)
                }
                .padding()
            } else {
                Text("TODO (maybe loading...)")
            }
        }
        .navigationTitle("Home")
        .toolbar(content: toolbar)
        .onAppear(perform: onAppear)
    }

    func toolbar() -> some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {}, label: {
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

    private func onAppear() {
        guard let apiKey = APIKey.getApiKeys().first else { return }
        let api = AppStoreConnectApi(apiKey: apiKey)
        api.getData().then { (data) in
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
