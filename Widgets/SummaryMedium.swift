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

    var body: some View {
        HStack(spacing: 0) {
            dateSection
            informationSection
                .padding([.vertical, .trailing], 12)
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
            UnitText(data.getAsString(.downloads, lastNDays: 1), metricSymbol: "square.and.arrow.down")
            GraphView(data.getRawData(.downloads, lastNDays: 30), color: color.readable(colorScheme: colorScheme))

            VStack(spacing: 0) {
                DescribedValueView(description: "LAST_SEVEN_DAYS", value: data.getAsString(.downloads, lastNDays: 7, size: .compact))
                DescribedValueView(description: "LAST_THIRTY_DAYS", value: data.getAsString(.downloads, lastNDays: 30, size: .compact))
            }
        }
    }

    var proceedsSection: some View {
        VStack(alignment: .leading, spacing: 5.0) {
            UnitText(data.getAsString(.proceeds, lastNDays: 1), metric: data.displayCurrency.symbol)
            GraphView(data.getRawData(.proceeds, lastNDays: 30), color: color.readable(colorScheme: colorScheme))

            VStack(spacing: 0) {
                DescribedValueView(description: "LAST_SEVEN_DAYS", value: data
                                    .getAsString(.proceeds, lastNDays: 7, size: .compact)
                                    .appending(data.displayCurrency.symbol))
                DescribedValueView(description: "LAST_THIRTY_DAYS", value: data
                                    .getAsString(.proceeds, lastNDays: 30, size: .compact)
                                    .appending(data.displayCurrency.symbol))
            }
        }
    }
}

struct SummaryMedium_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SummaryMedium(data: ACData.example, color: Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                .previewContext(WidgetPreviewContext(family: .systemMedium))

            SummaryMedium(data: ACData.example, color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)))
                .background(Color.widgetBackground)
                .preferredColorScheme(.dark)
                .previewContext(WidgetPreviewContext(family: .systemMedium))

            SummaryMedium(data: ACData.example, color: Color(#colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)))
                .background(Color.widgetBackground)
                .preferredColorScheme(.dark)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
