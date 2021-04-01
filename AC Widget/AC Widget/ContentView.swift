//
//  ContentView.swift
//  AC Widget
//
//  Created by Miká Kruschel on 29.03.21.
//

import SwiftUI

struct ContentView: View {
    @State var downloads: [(Int, Date)] = []
    @State var proceeds: [(Float, Date)] = []
    @State var currency: String = ""
    var body: some View {
        Text(downloads.map { day in
            "\(day.1.acApiFormat()) \(day.0)"
        }.joined(separator: "\n"))
        .onAppear {
            let api = AppStoreConnectApi(issuerID: "7430ebed-8822-4eaa-ba00-97592cdb38b2", privateKeyID: "D6MV79WMXC", privateKey: "MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQg7s/cjcr7ZxjWwiV/IIyPgMg4Ykg2CACvyzm/ZKBuEaygCgYIKoZIzj0DAQehRANCAARuaiARwBdMe7XJ0+pmaM64OtsEAVtSRcCzQcdJBfOCJS7bAazZNDodGGZBa60KJGYOIAxipWzN6kkWP+rYSqul", vendorNumber: "89258042")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
