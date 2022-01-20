//
//  SummarySmall.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import WidgetKit

struct SummarySmall: View {
    let data: ACData
    var color: Color = .accentColor
    let filteredApps: [ACApp]

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                Text(data.latestReportingDate())
                    .font(.subheadline)
                    .foregroundColor(.gray)

                UnitText(data.getRawData(for: .downloads, lastNDays: 1, filteredApps: filteredApps).toString(), metricSymbol: "square.and.arrow.down")
                UnitText(data.getRawData(for: .proceeds, lastNDays: 1, filteredApps: filteredApps).toString(), metric: data.displayCurrency.symbol)

                Spacer()
                    .frame(minHeight: 0)

                DescribedValueView(description: "LAST_SEVEN_DAYS",
                                   value: data.getRawData(for: .proceeds, lastNDays: 7, filteredApps: filteredApps)
                                    .toString(size: .compact)
                                    .appending(data.displayCurrency.symbol))
                DescribedValueView(description: "LAST_THIRTY_DAYS",
                                   value: data.getRawData(for: .proceeds, lastNDays: 30, filteredApps: filteredApps)
                                    .toString(size: .compact)
                                    .appending(data.displayCurrency.symbol))
            }
            .padding()
            AppIconStack(apps: filteredApps)
                .padding(12)
        }
    }
}

struct SummarySmall_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SummarySmall(data: ACData.example, filteredApps: [])
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
