//
//  SummarySmall.swift
//  AC Widget
//
//  Created by Cameron Shemilt on 01.04.21.
//

import SwiftUI
import WidgetKit

struct SummarySmall: View {
    let data: ACData
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(data.latestReportingDate())
                .font(.subheadline)
                .foregroundColor(.gray)
            
            UnitText(data.getDownloads(), metricSymbol: "square.and.arrow.down")
            
            UnitText(data.getProceeds(), metric: data.currency)
            
            Spacer()
            
            HStack {
                Text("Last 7 Days:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(data.getProceeds(7).appending(data.currency))
                    .font(.system(.headline, design: .rounded))
            }
            .minimumScaleFactor(0.8)
            .lineLimit(1)
            
            HStack {
                Text("Last 30 Days:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(data.getProceeds(30).appending(data.currency))
                    .font(.system(.headline, design: .rounded))
            }
            .minimumScaleFactor(0.8)
            .lineLimit(1)
        }
        .padding()
    }
}

struct SummarySmall_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SummarySmall(data: ACData.example)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            SummarySmall(data: ACData.exampleLargeSums)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
