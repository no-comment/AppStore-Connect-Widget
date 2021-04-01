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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
