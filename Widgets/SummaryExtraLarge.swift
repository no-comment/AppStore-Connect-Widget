//
//  SummaryExtraLarge.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import WidgetKit

struct SummaryExtraLarge: View {
    @Environment(\.colorScheme) var colorScheme

    let data: ACData
    var color: Color = .accentColor
    let filteredApps: [ACApp]

    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack {
                dateSection
                VStack(spacing: 12) {
                    generalReportSection
                    appDetailSection
                    otherInformationSection
                }
                .padding([.vertical, .trailing], 12)
                .padding(.leading, 8)
            }
            AppIconStack(apps: filteredApps)
                .padding(.top, 10)
                .padding(.leading, 25)
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

    var generalReportSection: some View {
        HStack(spacing: 12) {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    UnitText(data.getAsString(.downloads, lastNDays: 1, filteredApps: filteredApps), metricSymbol: "square.and.arrow.down")
                }
                DescribedValueView(description: "LAST_SEVEN_DAYS", value: data.getAsString(.downloads, lastNDays: 7, size: .compact, filteredApps: filteredApps))
                DescribedValueView(description: "LAST_THIRTY_DAYS", value: data.getAsString(.downloads, lastNDays: 30, size: .compact, filteredApps: filteredApps))
            }
            GraphView(data.getRawData(.downloads, lastNDays: 30, filteredApps: filteredApps), color: color.readable(colorScheme: colorScheme))

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    UnitText(data.getAsString(.proceeds, lastNDays: 1, filteredApps: filteredApps), metric: data.displayCurrency.symbol)
                }
                DescribedValueView(description: "LAST_SEVEN_DAYS", value: data
                                    .getAsString(.proceeds, lastNDays: 7, size: .compact, filteredApps: filteredApps)
                                    .appending(data.displayCurrency.symbol))
                DescribedValueView(description: "LAST_THIRTY_DAYS", value: data
                                    .getAsString(.proceeds, lastNDays: 30, size: .compact, filteredApps: filteredApps)
                                    .appending(data.displayCurrency.symbol))
            }
            GraphView(data.getRawData(.proceeds, lastNDays: 30, filteredApps: filteredApps), color: color.readable(colorScheme: colorScheme))
        }
    }

    var appDetailSection: some View {
        HStack(spacing: 16) {
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
                        Spacer()
                        UnitText(data.getAsString(.downloads, lastNDays: 1, filteredApps: [app]), metricSymbol: InfoType.downloads.systemImage)
                            .fontSize(19)
                        Spacer()
                        UnitText(data.getAsString(.proceeds, lastNDays: 1, filteredApps: [app]), metric: data.displayCurrency.symbol)
                            .fontSize(19)
                        if (filteredApps.count != 0 && filteredApps.count <= 3) || (filteredApps.count == 0 && data.apps.count <= 3) {
                            Spacer()
                            UnitText(data.getAsString(.iap, lastNDays: 1, filteredApps: [app]), metricSymbol: InfoType.iap.systemImage)
                                .fontSize(19)
                        }
                        if (filteredApps.count != 0 && filteredApps.count <= 2) || (filteredApps.count == 0 && data.apps.count <= 2) {
                            Spacer()
                            UnitText(data.getAsString(.updates, lastNDays: 1, filteredApps: [app]), metricSymbol: InfoType.updates.systemImage)
                                .fontSize(19)
                        }
                    }
                }
            }
        }
    }

    var otherInformationSection: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Spacer()
                Group {
                    HStack {
                        Image(systemName: InfoType.downloads.systemImage)
                            .foregroundColor(.gray)
                        PercentStackedBarChart(data:
                                                data.getDevices(.downloads, lastNDays: 30, filteredApps: filteredApps)
                                                .sorted(by: { $0.0 < $1.0 })
                                                .map({ ($0.1, ACDevice($0.0).color) })
                        )
                            .frame(height: 10)
                    }
                    HStack {
                        ZStack {
                            Image(systemName: "circle.fill")
                                .foregroundColor(.secondaryCardColor)
                            Text(data.displayCurrency.symbol)
                                .foregroundColor(.gray)
                        }
                        PercentStackedBarChart(data:
                                                data.getDevices(.proceeds, lastNDays: 30, filteredApps: filteredApps)
                                                .sorted(by: { $0.0 < $1.0 })
                                                .map({ ($0.1, ACDevice($0.0).color) })
                        )
                            .frame(height: 10)
                    }
                    HStack {
                        Image(systemName: InfoType.iap.systemImage)
                            .foregroundColor(.gray)
                        PercentStackedBarChart(data:
                                                data.getDevices(.iap, lastNDays: 30, filteredApps: filteredApps)
                                                .sorted(by: { $0.0 < $1.0 })
                                                .map({ ($0.1, ACDevice($0.0).color) })
                        )
                            .frame(height: 10)
                    }
                    HStack {
                        Image(systemName: InfoType.updates.systemImage)
                            .foregroundColor(.gray)
                        PercentStackedBarChart(data:
                                                data.getDevices(.updates, lastNDays: 30, filteredApps: filteredApps)
                                                .sorted(by: { $0.0 < $1.0 })
                                                .map({ ($0.1, ACDevice($0.0).color) })
                        )
                            .frame(height: 10)
                    }
                }
                .font(.system(size: 10))
                Spacer()
                HStack {
                    Spacer()
                    ForEach(ACDevice.allCases) { device in
                        ZStack {
                            Circle()
                                .foregroundColor(device.color)
                                .frame(width: 20, height: 20)
                            Image(systemName: device.symbol)
                                .font(.system(size: 10, weight: .bold))
                        }
                        Spacer()
                    }
                }
            }
            .font(.system(size: 13))

            VStack(alignment: .leading, spacing: 0) {
                Text("TOP_COUNTRIES")
                    .padding(.bottom, 3)
                Spacer()
                DescribedValueView(description: countryName(placement: 0), value: countryProceeds(placement: 0))
                DescribedValueView(description: countryName(placement: 1), value: countryProceeds(placement: 1))
                DescribedValueView(description: countryName(placement: 2), value: countryProceeds(placement: 2))
                DescribedValueView(description: countryName(placement: 3), value: countryProceeds(placement: 3))
            }

            VStack(alignment: .leading) {
                Text("UPDATES")
                GraphView(data.getRawData(.updates, lastNDays: 30, filteredApps: filteredApps), color: color.readable(colorScheme: colorScheme))
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

struct SummaryExtraLarge_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SummaryExtraLarge(data: ACData.example, filteredApps: [ACApp.mockApp, ACApp.mockApp, ACApp.mockApp])
                .previewContext(WidgetPreviewContext(family: .systemExtraLarge))

            SummaryExtraLarge(data: ACData.example, filteredApps: [])
                .background(Color.widgetBackground)
                .preferredColorScheme(.dark)
                .previewContext(WidgetPreviewContext(family: .systemExtraLarge))

        }
    }
}
