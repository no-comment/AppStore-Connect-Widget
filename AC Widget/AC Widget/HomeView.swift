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
    @AppStorage(UserDefaultsKey.issuerID, store: UserDefaults.shared) var issuerID: String = ""
    @AppStorage(UserDefaultsKey.privateKeyID, store: UserDefaults.shared) var privateKeyID: String = ""
    @AppStorage(UserDefaultsKey.privateKey, store: UserDefaults.shared) var privateKey: String = ""
    @AppStorage(UserDefaultsKey.vendorNumber, store: UserDefaults.shared) var vendorNumber: String = ""
    
    var body: some View {
        ScrollView {
            if data != nil {
                SummaryMedium(data: data!)
                    .showAsWidget(.systemMedium)
            } else if error != nil {
                ErrorWidget(error: error!)
                    .showAsWidget(.systemMedium)
            } else {
                ErrorWidget(error: .unknown)
                    .showAsWidget(.systemMedium)
            }
            
            HStack {
                Spacer()
            }
        }
        .navigationTitle("Home")
        .toolbar(content: toolbar)
        .onAppear(perform: onAppear)
    }
    
    func toolbar() -> some ToolbarContent {
        ToolbarItem {
            NavigationLink(destination: SettingsView(),
                           label: { Image(systemName: "gear") }
            )
        }
    }
    
    private func onAppear() {
        let api = AppStoreConnectApi(issuerID: issuerID, privateKeyID: privateKeyID, privateKey: privateKey, vendorNumber: vendorNumber)
        api.getData().then { (data) in
            self.data = data
        }.catch { (err) in
            print(err)
            guard let apiErr = err as? APIError else {
                return
            }
            self.error = apiErr
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView(data: ACData.example)
        }
    }
}
