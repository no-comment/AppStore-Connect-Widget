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
    var color: Color = .accentColor

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(data.latestReportingDate())
                .font(.subheadline)
                .foregroundColor(.gray)

            UnitText(data.getDownloadsString(), metricSymbol: "square.and.arrow.down")
            UnitText(data.getProceedsString(), metric: data.displayCurrency.symbol)

            Spacer()
                .frame(minHeight: 0)

            DescribedValueView(description: "LAST_SEVEN_DAYS", value: data.getProceedsString(7, size: .compact).appending(data.displayCurrency.symbol))
            DescribedValueView(description: "LAST_THIRTY_DAYS", value: data.getProceedsString(30, size: .compact).appending(data.displayCurrency.symbol))
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
