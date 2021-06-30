//
//  DeviceTile.swift
//  AC Widget
//
//  Created by Cameron Shemilt on 30.06.21.
//

import SwiftUI

struct DeviceTile: View {
    private var data: ACData
    private var colors: [Color]
    
    init(data: ACData, colors: [Color] = [.accentColor, .red, .yellow, .green, .purple, .pink]) {
        <#statements#>
    }
    
    var body: some View {
        Text("")
    }
}

struct DeviceTile_Previews: PreviewProvider {
    static var previews: some View {
        DeviceTile(data: ACData.example)
    }
}
