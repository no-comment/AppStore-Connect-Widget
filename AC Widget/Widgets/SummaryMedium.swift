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
        VStack(alignment: .leading) {
            UnitText(data.getDownloads(), metricSymbol: "square.and.arrow.down")
            
            Spacer()
            
            HStack {
                Text("Last 7 Days:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            
                Spacer()
            
                Text(data.getDownloads(7))
                    .font(.system(.headline, design: .rounded))
            }
            .minimumScaleFactor(0.8)
            .lineLimit(1)
            
            HStack {
                Text("Last 30 Days:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(data.getDownloads(30))
                    .font(.system(.headline, design: .rounded))
            }
            .minimumScaleFactor(0.8)
            .lineLimit(1)
        }
    }
    
    var proceedsSection: some View {
        VStack(alignment: .leading) {
            UnitText(data.getProceeds(), metric: data.currency)
                        
            Spacer()
            
            HStack {
                Text("Last 7 Days:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(data.getProceeds(7, size: .compact).appending(data.currency))
                    .font(.system(.headline, design: .rounded))
            }
            .minimumScaleFactor(0.8)
            .lineLimit(1)
            
            HStack {
                Text("Last 30 Days:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(data.getProceeds(30, size: .compact).appending(data.currency))
                    .font(.system(.headline, design: .rounded))
            }
            .minimumScaleFactor(0.8)
            .lineLimit(1)
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
