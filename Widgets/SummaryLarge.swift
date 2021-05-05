//
//  SummaryLarge.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import WidgetKit

struct SummaryLarge: View {
    @Environment(\.colorScheme) var colorScheme

    let data: ACData
    var color: Color = .accentColor

    var body: some View {
        VStack {
            dateSection
            informationSection
                .padding([.horizontal, .bottom], 14)
        }
    }

    var dateSection: some View {
        Text(data.latestReportingDate())
            .font(.subheadline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(Color.widgetSecondary)
    }

    var informationSection: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top, spacing: 0) {
                downloadsSection
                Spacer()
                Spacer()
                proceedsSection
            }
            countriesSection
        }
    }

    var downloadsSection: some View {
        VStack(alignment: .leading, spacing: 5.0) {
            UnitText(data.getAsString(.downloads, lastNDays: 1), metricSymbol: "square.and.arrow.down")
            GraphView(data.getRawData(.downloads, lastNDays: 30), color: color.readable(colorScheme: colorScheme))

            VStack(spacing: 0) {
                DescribedValueView(description: "LAST_SEVEN_DAYS", value: data
                                    .getAsString(.downloads, lastNDays: 7, size: .compact))
                DescribedValueView(description: "LAST_THIRTY_DAYS", value: data
                                    .getAsString(.downloads, lastNDays: 30, size: .compact))
                DescribedValueView(description: "MONTH_TO_DATE", value: data
                                    .getAsString(.downloads, lastNDays: Date.dateToMonthNumber(), size: .compact))
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
                DescribedValueView(description: "MONTH_TO_DATE", value: data
                                    .getAsString(.proceeds, lastNDays: Date.dateToMonthNumber(), size: .compact)
                                    .appending(data.displayCurrency.symbol))
            }
        }
    }

    var countriesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("TOP_COUNTRIES")
                .font(.system(size: 18, weight: .medium, design: .default))
                .padding(.bottom, 3)

            DescribedValueView(description: countryName(placement: 0), value: countryProceeds(placement: 0))
            DescribedValueView(description: countryName(placement: 1), value: countryProceeds(placement: 0))
            DescribedValueView(description: countryName(placement: 2), value: countryProceeds(placement: 0))
        }
    }
    
    private func countryName(placement: Int) -> String {
        let countries = data.getCountries(.proceeds, lastNDays: 30).sorted(by: { $0.1 > $1.1 })
        if placement < countries.count {
            return countries[placement].0
        }
        return ""
    }
    
    private func countryProceeds(placement: Int) -> String {
        let countries = data.getCountries(.proceeds, lastNDays: 30).sorted(by: { $0.1 > $1.1 })
        if placement < countries.count {
            let nf = NumberFormatter()
            nf.numberStyle = .decimal
            nf.maximumFractionDigits = 1
            let number = NSNumber(value: countries[placement].1)
            if let string = nf.string(from: number) {
                return string.appending(data.displayCurrency.symbol)
            }
        }
        return ""
    }
}

struct SummaryLarge_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SummaryLarge(data: ACData.example)
                .previewContext(WidgetPreviewContext(family: .systemLarge))

            SummaryLarge(data: ACData.example)
                .background(Color.widgetBackground)
                .preferredColorScheme(.dark)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
