//
//  UnitText.swift
//  AC Widget
//
//  Created by Cameron Shemilt on 01.04.21.
//

import SwiftUI
import WidgetKit

struct UnitText: View {
    let text: String
    let metricString: String?
    let metricImage: String?
    var fontSize: CGFloat = 30
    
    init(_ text: String, metric: String) {
        self.text = text
        self.metricString = metric
        self.metricImage = nil
    }
    
    init(_ text: String, metricSymbol: String) {
        self.text = text
        self.metricString = nil
        self.metricImage = metricSymbol
    }
    
    var body: some View {
        HStack(alignment:.bottom, spacing: fontSize*0.17) {
            HStack(alignment: .top, spacing: 0) {
                Text(text)
                
                if metricString != nil {
                    Text(metricString!)
                        .font(.system(size: fontSize*0.5, weight: .semibold, design: .rounded) )
                        //.font(.system(size: fontSize*0.5))
                        .padding(.top, fontSize*0.1)
                        .hideWhenRedacted()
                }
                
                if metricImage != nil {
                    Image(systemName: metricImage!)
                        .font(.system(size: fontSize*0.48, weight: .semibold, design: .default) )
                        .padding(.top, fontSize*0.1)
                        .hideWhenRedacted()
                }
            }
            .font(.system(size: fontSize, weight: .semibold, design: .rounded))
            .minimumScaleFactor(0.8)
        }
        .lineLimit(1)
    }
    
    func fontSize(_ fontSize: CGFloat) -> some View{
        var copy = self
        copy.fontSize = fontSize
        return copy
    }
}

struct UnitText_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UnitText("45.3", metric: "$")
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            UnitText("4.8k", metricSymbol: "square.and.arrow.down")
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            VStack {
                HStack {
                    Spacer()
                    UnitText("253", metric: "€")
                        .fontSize(35)
                }
                Spacer()
            }
            .padding()
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
