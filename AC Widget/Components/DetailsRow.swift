//
//  DetailsRow.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
// infotype
struct DetailsRow: View {
    @EnvironmentObject private var dataProvider: ACDataProvider
    public let infoType: InfoType

    @State private var currentMonthData: [RawDataPoint] = []
    @State private var currentDay: RawDataPoint = (0, .now)
    //    {
    //        return
    //    }

    @State private var noData = true

    var body: some View {
        Card(spacing: 15, innerPadding: 10) {
            HStack {
                Label(infoType.title, systemImage: infoType.systemImage)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(infoType.color)
                    .unredacted()

                Spacer()

                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(currentDay.1.reportingDate())
                    Image(systemName: "chevron.right").unredacted()
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            HStack(alignment: .bottom) {
                UnitText(currentDay.0.toString(abbreviation: .intelligent, maxFractionDigits: 2), infoType: infoType, currencySymbol: dataProvider.displayCurrencySymbol)
                Spacer(minLength: 70)
                GraphView(currentMonthData, color: infoType.color)
                    .frame(maxWidth: 230)
            }
            .frame(minHeight: 50)
        }
        .noDataOverlay(noData, short: true)
        .onAppear(perform: refresh)
        .onReceive(dataProvider.$data) { _ in refresh() }
        .frame(height: 90)
    }

    private func refresh() {
        guard let data = dataProvider.data else {
            showNoData()
            return
        }

        currentMonthData = data.getRawData(for: infoType, lastNDays: 30)

        guard !currentMonthData.isEmpty else {
            showNoData()
            return
        }

        currentDay = data.getLastRawData(for: infoType)

        noData = false
    }

    private func showNoData() {
        currentMonthData = ACData.createExampleData(30)
        currentDay = (Float(Int.random(in: 7...30)), .now)

        noData = true
    }
}

struct DetailsRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DetailsRow(infoType: .iap)
                .padding()
                .environmentObject(ACDataProvider.example)
            DetailsRow(infoType: .iap)
                .padding()
                .environmentObject(ACDataProvider.exampleNoData)
        }
        .secondaryBackground()
    }
}
