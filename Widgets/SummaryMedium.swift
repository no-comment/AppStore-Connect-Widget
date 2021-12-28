//
//  SummaryMedium.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import WidgetKit

struct SummaryMedium: View {
    @Environment(\.colorScheme) var colorScheme

    let data: ACData
    var color: Color = .accentColor
    let filteredApps: [ACApp]

    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(spacing: 0) {
                dateSection
                informationSection
                    .padding([.vertical, .trailing], 12)
            }
            AppIconStack(apps: filteredApps)
                .padding(12)
        }
    }

    var dateSection: some View {
        Text(data.latestReportingDate())
            .font(.subheadline)
            .rotationEffect(.degrees(-90))
            .fixedSize()
            .frame(maxWidth: 30, maxHeight: .infinity)
            .background(Color.widgetSecondary)
    }

    var informationSection: some View {
        HStack(alignment: .top, spacing: 0) {
            Spacer()
            downloadsSection
            Spacer()
            Spacer()
            Spacer()
            proceedsSection
            Spacer()
        }
    }

    var downloadsSection: some View {
        VStack(alignment: .leading, spacing: 5.0) {
            UnitText(data.getRawData(for: .downloads, lastNDays: 1, filteredApps: filteredApps).toString(), metricSymbol: "square.and.arrow.down")
            GraphView(data.getRawData(for: .downloads, lastNDays: 30, filteredApps: filteredApps), color: color.readable(colorScheme: colorScheme))

            VStack(spacing: 0) {
                DescribedValueView(description: "LAST_SEVEN_DAYS", value: data.getRawData(for: .downloads, lastNDays: 7, filteredApps: filteredApps).toString(size: .compact))
                DescribedValueView(description: "LAST_THIRTY_DAYS", value: data.getRawData(for: .downloads, lastNDays: 30, filteredApps: filteredApps).toString(size: .compact))
            }
        }
    }

    var proceedsSection: some View {
        VStack(alignment: .leading, spacing: 5.0) {
            UnitText(data.getRawData(for: .proceeds, lastNDays: 1, filteredApps: filteredApps).toString(), metric: data.displayCurrency.symbol)
            GraphView(data.getRawData(for: .proceeds, lastNDays: 30, filteredApps: filteredApps), color: color.readable(colorScheme: colorScheme))

            VStack(spacing: 0) {
                DescribedValueView(description: "LAST_SEVEN_DAYS", value: data
                                    .getRawData(for: .proceeds, lastNDays: 7, filteredApps: filteredApps).toString(size: .compact)
                                    .appending(data.displayCurrency.symbol))
                DescribedValueView(description: "LAST_THIRTY_DAYS", value: data
                                    .getRawData(for: .proceeds, lastNDays: 30, filteredApps: filteredApps).toString(size: .compact)
                                    .appending(data.displayCurrency.symbol))
            }
        }
    }
}

struct SummaryMedium_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SummaryMedium(data: ACData.example, filteredApps: [ACApp.mockApp, ACApp.mockApp, ACApp.mockApp])
                .previewContext(WidgetPreviewContext(family: .systemMedium))

            SummaryMedium(data: ACData.example, filteredApps: [])
                .background(Color.widgetBackground)
                .preferredColorScheme(.dark)
                .previewContext(WidgetPreviewContext(family: .systemMedium))

        }
    }
}
