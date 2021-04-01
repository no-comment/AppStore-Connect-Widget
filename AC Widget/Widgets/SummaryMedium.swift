//
//  SummaryMedium.swift
//  AC Widget
//
//  Created by Cameron Shemilt on 01.04.21.
//

import SwiftUI
import WidgetKit

struct SummaryMedium: View {
    let data: ACData
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Spacer()
            downloadsSection
            Spacer()
            Spacer()
            Spacer()
            proceedsSection
            Spacer()
        }
        .padding(12)
    }
    
    var downloadsSection: some View {
        VStack(alignment: .leading, spacing: 5.0) {
            UnitText(data.getDownloads(), metricSymbol: "square.and.arrow.down")
            GraphView(data.getDownloads(30))
            
            VStack(spacing: 0) {
                DescribedValueView("7 Days:", value: data.getDownloads(7, size: .compact))
                DescribedValueView("30 Days:", value: data.getDownloads(30, size: .compact))
            }
        }
    }
    
    var proceedsSection: some View {
        VStack(alignment: .leading, spacing: 5.0) {
            UnitText(data.getProceeds(), metric: data.currency)
            GraphView(data.getProceeds(30))
            
            VStack(spacing: 0) {
                DescribedValueView("7 Days:", value: data.getProceeds(7, size: .compact).appending(data.currency))
                DescribedValueView("30 Days:", value: data.getProceeds(30, size: .compact).appending(data.currency))
            }
        }
    }
}

struct SummaryMedium_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SummaryMedium(data: ACData.example)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            SummaryMedium(data: ACData.exampleLargeSums)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
