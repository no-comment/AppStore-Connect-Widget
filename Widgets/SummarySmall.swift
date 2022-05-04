//
//  SummarySmall.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import WidgetKit

struct SummarySmall: View {
    let data: ACData
    let error: APIError?
    var color: Color = .accentColor
    let filteredApps: [ACApp]

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                Text(data.latestReportingDate())
                    .font(.subheadline)
                    .foregroundColor(.gray)

                UnitText(data.getRawData(for: .downloads, lastNDays: 1, filteredApps: filteredApps).toString(), infoType: .downloads)
                UnitText(data.getRawData(for: .proceeds, lastNDays: 1, filteredApps: filteredApps).toString(), infoType: .proceeds, currencySymbol: data.displayCurrency.symbol)

                Spacer(minLength: 5)

                DescribedValueView(description: "LAST_SEVEN_DAYS",
                                   value: data.getRawData(for: .proceeds, lastNDays: 7, filteredApps: filteredApps)
                    .toString(size: .compact)
                    .appending(data.displayCurrency.symbol))
                DescribedValueView(description: "LAST_THIRTY_DAYS",
                                   value: data.getRawData(for: .proceeds, lastNDays: 30, filteredApps: filteredApps)
                    .toString(size: .compact)
                    .appending(data.displayCurrency.symbol))

                if let error = error {
                    Label(error.userTitle, systemImage: "exclamationmark.circle")
                        .font(.caption2)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 5)
                }
            }
            .padding()

            AppIconStack(apps: filteredApps)
                .padding(12)
        }
    }
}

struct SummarySmall_Previews: PreviewProvider {
    static var previews: some View {
        SummarySmall(data: ACData.example, error: .noDataAvailable, filteredApps: [])
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
