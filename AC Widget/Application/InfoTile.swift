//
//  InfoTile.swift
//  AC Widget
//
//  Created by Cameron Shemilt on 16.04.21.
//

import SwiftUI

struct InfoTile: View {
    private var description: LocalizedStringKey
    private var data: ACData
    private var type: InfoType
    private var color: Color
    
    @State private var currentIndex: Int?
    private var graphData: [CGFloat] {
        let copy = data.getRawData(type, lastNDays: 30).map { $0.0 }
        let max: Float = copy.max() ?? 1
        return copy.map { CGFloat($0 / max) }.reversed()
    }
    
    init(description: LocalizedStringKey, data: ACData, type: InfoType, color: Color = .accentColor) {
        self.description = description
        self.data = data
        self.type = type
        self.color = color
    }
    
    var body: some View {
        Card {
            topSection
            graphSection
                .frame(minHeight: 100)
            bottomSection
        }
        .frame(height: 220)
    }
    
    var topSection: some View {
        HStack(alignment: .top) {
            if let index = currentIndex {
                let foo = data.getRawData(type, lastNDays: 30)[index]
                Text(foo.1.toString())
                    .font(.system(size: 20))
                Spacer()
                UnitText(ACData.formatNumberLength(num: foo.0, type: type), metric: "$")
            } else {
                Text(description)
                    .font(.system(size: 20))
                Spacer()
                UnitText(data.getAsString(type, lastNDays: 1), metric: "$")
            }
        }
    }
    
    var graphSection: some View {
        Group {
            if !graphData.isEmpty {
                GeometryReader { reading in
                    HStack(alignment: .bottom, spacing: 0) {
                        ForEach(graphData.indices) { i in
                            Capsule()
                                .frame(width: (reading.size.width/CGFloat(graphData.count))*0.7, height: reading.size.height * getGraphHeight(i))
                                .foregroundColor(getGraphColor(i))
                            
                            if i != graphData.count-1 {
                                Spacer()
                                    .frame(minWidth: 0)
                            }
                        }
                    }
                }
            } else {
                Text("NO_DATA")
                    .foregroundColor(.gray)
                    .italic()
            }
        }
    }
    
    private func getGraphHeight(_ i: Int) -> CGFloat {
        if i < graphData.count && graphData[i] > 0 {
            return graphData[i]
        }
        if i < graphData.count && graphData[i] < 0 {
            return abs(graphData[i])
        }
        return 0.01
    }
    
    private func getGraphColor(_ i: Int) -> Color {
        if i < graphData.count && graphData[i] > 0 {
            return color
        }
        if i < graphData.count && graphData[i] < 0 {
            return .red
        }
        return .gray
    }
    
    var bottomSection: some View {
        HStack(alignment: .bottom) {
            DescribedValueView(description: "LAST_SEVEN_DAYS", value: ("123$"))
            Spacer()
                .frame(width: 40)
            DescribedValueView(description: "LAST_THIRTY_DAYS", value: "400$")
        }
    }
}

struct InfoTile_Previews: PreviewProvider {
    static var previews: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 320))], spacing: 8) {
            InfoTile(description: "DOWNLOADS", data: ACData.example, type: .downloads)
            InfoTile(description: "PROCEEDS", data: ACData.example, type: .proceeds)
        }.padding()
    }
}
