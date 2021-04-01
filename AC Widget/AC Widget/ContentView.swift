//
//  ContentView.swift
//  AC Widget
//
//  Created by Miká Kruschel on 29.03.21.
//

import SwiftUI
import AppStoreConnect_Swift_SDK

struct ContentView: View {
    @State var data: ACData?
    let api = AppStoreConnectApi(issuerID: "", privateKeyID: "", privateKey: "", vendorNumber: "")
    
    var body: some View {
        Text((data?.getProceeds() ?? "No Data") + (data?.currency ?? ""))
        .onAppear {
            api.getData().then { (data) in
                self.data = data
            }.catch { (err) in
                print(err)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
