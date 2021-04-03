//
//  GraphView.swift
//  AC Widget
//
//  Created by Cameron Shemilt on 01.04.21.
//

import SwiftUI
import WidgetKit

struct GraphView: View {
    let data: [CGFloat]
    
    init(_ data: [(Float, Date)]) {
        let copy = data.map { $0.0 }
        let max: Float = copy.max() ?? 1
        self.data = copy.map { CGFloat($0 / max) }.reversed()
    }
    
    init(_ data: [(Int, Date)]) {
        let copy = data.map { Float($0.0) }
        let max: Float = copy.max() ?? 1
        self.data = copy.map { CGFloat($0 / max) }.reversed()
    }
    
    var body: some View {
        if !data.isEmpty {
            GeometryReader { reading in
                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(data.indices) { i in
                        Capsule()
                            .frame(width: (reading.size.width/CGFloat(data.count))*0.7 ,height: reading.size.height * getHeight(i))
                            .foregroundColor(.accentColor)
                        
                        if i != data.count-1 {
                            Spacer()
                                .frame(minWidth: 0)
                        }
                    }
                }
            }
        } else {
            Text("No Data")
                .foregroundColor(.gray)
                .italic()
        }
    }
    
    private func getHeight(_ i: Int) -> CGFloat {
        return (i >= data.count || data[i] == 0) ? 0.01 : data[i]
    }
}

struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GraphView(ACData.example.getDownloads(30))
                .padding()
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            GraphView(ACData.example.getProceeds(30))
                .padding()
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            GraphView([(Float, Date)]())
                .padding()
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
