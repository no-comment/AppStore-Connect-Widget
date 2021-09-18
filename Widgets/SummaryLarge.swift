//
//  SummaryLarge.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import WidgetKit
import BetterToStrings

struct SummaryLarge: View {
    @Environment(\.colorScheme) var colorScheme

    let data: ACData
    var color: Color = .accentColor
    let filteredApps: [ACApp]

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                dateSection
                informationSection
                    .padding([.horizontal, .bottom], 14)
            }
            AppIconStack(apps: filteredApps)
                .padding(.top, 7.5)
                .padding(.trailing, 18)
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
            if filteredApps.count == 1 || data.apps.count <= 1 {
                countriesSection
            } else {
                appList
            }
        }
    }

    var downloadsSection: some View {
        VStack(alignment: .leading, spacing: 5.0) {
            UnitText(data.getAsString(.downloads, lastNDays: 1, filteredApps: filteredApps), metricSymbol: "square.and.arrow.down")
            GraphView(data.getRawData(.downloads, lastNDays: 30, filteredApps: filteredApps), color: color.readable(colorScheme: colorScheme))

            VStack(spacing: 0) {
                DescribedValueView(description: "LAST_SEVEN_DAYS", value: data
                                    .getAsString(.downloads, lastNDays: 7, size: .compact, filteredApps: filteredApps))
                DescribedValueView(description: "LAST_THIRTY_DAYS", value: data
                                    .getAsString(.downloads, lastNDays: 30, size: .compact, filteredApps: filteredApps))
                DescribedValueView(descriptionString: data.latestReportingDate().toString(format: "MMMM").appending(":"),
                                   value: data.getAsString(.downloads, lastNDays: data.latestReportingDate().dateToMonthNumber(), size: .compact, filteredApps: filteredApps))
            }
        }
    }

    var proceedsSection: some View {
        VStack(alignment: .leading, spacing: 5.0) {
            UnitText(data.getAsString(.proceeds, lastNDays: 1, filteredApps: filteredApps), metric: data.displayCurrency.symbol)
            GraphView(data.getRawData(.proceeds, lastNDays: 30, filteredApps: filteredApps), color: color.readable(colorScheme: colorScheme))

            VStack(spacing: 0) {
                DescribedValueView(description: "LAST_SEVEN_DAYS", value: data
                                    .getAsString(.proceeds, lastNDays: 7, size: .compact, filteredApps: filteredApps)
                                    .appending(data.displayCurrency.symbol))
                DescribedValueView(description: "LAST_THIRTY_DAYS", value: data
                                    .getAsString(.proceeds, lastNDays: 30, size: .compact, filteredApps: filteredApps)
                                    .appending(data.displayCurrency.symbol))
                DescribedValueView(descriptionString: data.latestReportingDate().toString(format: "MMMM").appending(":"),
                                   value: data
                                    .getAsString(.proceeds, lastNDays: data.latestReportingDate().dateToMonthNumber(), size: .compact, filteredApps: filteredApps)
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
            DescribedValueView(description: countryName(placement: 1), value: countryProceeds(placement: 1))
            DescribedValueView(description: countryName(placement: 2), value: countryProceeds(placement: 2))
        }
    }

    var fewApps: Bool {
        filteredApps.count == 2 || (filteredApps.count == 0 && data.apps.count == 2)
    }

    var appList: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: fewApps ? 300 : 100))], spacing: 8) {
            ForEach((filteredApps.isEmpty ? data.apps : filteredApps).prefix(4)) { app in
                Card(alignment: .leading, spacing: 3, innerPadding: 8, color: .cardColor) {
                    HStack(spacing: 4) {
                        Group {
                            if let data = app.artwork60ImgData, let uiImg = UIImage(data: data) {
                                Image(uiImage: uiImg)
                                    .resizable()
                            } else {
                                Rectangle().foregroundColor(.secondary)
                            }
                        }
                        .frame(width: 15, height: 15)
                        .cornerRadius(4)

                        Text(app.name)
                            .lineLimit(1)
                        Spacer()
                    }

                    HStack(alignment: .bottom) {
                        UnitText(data.getAsString(.downloads, lastNDays: 1, filteredApps: [app]), metricSymbol: InfoType.downloads.systemImage)
                            .fontSize(fewApps ? 25 : 19)
                        Spacer()
                        UnitText(data.getAsString(.proceeds, lastNDays: 1, filteredApps: [app]), metric: data.displayCurrency.symbol)
                            .fontSize(fewApps ? 25 : 19)
                        if fewApps {
                            Spacer()
                            UnitText(data.getAsString(.iap, lastNDays: 1, filteredApps: [app]), metricSymbol: InfoType.iap.systemImage)
                                .fontSize(25)
                        }
                    }
                }
            }
        }
    }

    private func countryName(placement: Int) -> LocalizedStringKey {
        let countries = data.getCountries(.proceeds, lastNDays: 30, filteredApps: filteredApps).sorted(by: { $0.1 > $1.1 })
        if placement < countries.count {
            return LocalizedStringKey(countries[placement].0.countryCodeToName())
        }
        return ""
    }

    private func countryProceeds(placement: Int) -> String {
        let countries = data.getCountries(.proceeds, lastNDays: 30, filteredApps: filteredApps).sorted(by: { $0.1 > $1.1 })
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
            SummaryLarge(data: ACData.example, filteredApps: [ACApp.mockApp])
                .previewContext(WidgetPreviewContext(family: .systemLarge))

            SummaryLarge(data: ACData.example, filteredApps: [])
                .background(Color.widgetBackground)
                .preferredColorScheme(.dark)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
