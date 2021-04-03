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
        VStack(alignment: .leading, spacing: 0) {
            Text(data.latestReportingDate())
                .font(.subheadline)
                .foregroundColor(.gray)
                        
            UnitText(data.getDownloads(), metricSymbol: "square.and.arrow.down")
            UnitText(data.getProceeds(), metric: data.currency)
            
            Spacer()
                .frame(minHeight: 0)
            
            DescribedValueView("LAST_SEVEN_DAYS", value: data.getProceeds(7, size: .compact).appending(data.currency))
            DescribedValueView("LAST_THIRTY_DAYS", value: data.getProceeds(30, size: .compact).appending(data.currency))
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
