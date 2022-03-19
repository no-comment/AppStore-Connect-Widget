//
//  WeeklyAverageCard.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import BetterToStrings

struct WeeklyAverageCard: View {
    @EnvironmentObject private var dataProvider: ACDataProvider
    let type: InfoType
    let header: Bool
    @State private var title: String = ""
    @State private var data: [RawDataPoint] = []
    @State private var average: Float = 1
    @State private var max: Float = 1

    @State private var noData = true

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                if header {
                    Label(type.title, systemImage: type.systemImage)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(type.color)
                        .unredacted()
                }
                Text(title)
                    .font(.title2.weight(.semibold))
                Divider()
                ZStack(alignment: .top) {
                    graph
                    line
                }
            }
            .noDataOverlay(noData)
        }
        .onAppear(perform: refresh)
        .onReceive(dataProvider.$data) { _ in refresh() }
    }

    private func refresh() {
        guard let acData = dataProvider.data else {
            showNoData()
            return
        }

        let rawData = acData.getRawData(for: type, lastNDays: 7)

        guard !rawData.isEmpty else {
            showNoData()
            return
        }

        self.data = rawData
        self.average = rawData.isEmpty ? .infinity : rawData.map(\.0).reduce(0, +) / Float(rawData.count)
        self.max = rawData.map(\.0).max() ?? 1

        switch type {
        case .downloads:
            self.title = "You had an average of \(average.toString(abbreviation: .intelligent, maxFractionDigits: 1)) downloads this week."
        case .proceeds:
            self.title = "You earned an average of \(average.toString(abbreviation: .intelligent, maxFractionDigits: 2))\(acData.displayCurrency.symbol) this week."
        case .updates:
            self.title = "You had an average of \(average.toString(abbreviation: .intelligent, maxFractionDigits: 1)) updates this week."
        case .iap:
            self.title = "You had an average of \(average.toString(abbreviation: .intelligent, maxFractionDigits: 1)) in-app purchases this week."
        case .reDownloads:
            self.title = "You had an average of \(average.toString(abbreviation: .intelligent, maxFractionDigits: 1)) re-downloads this week."
        case .restoredIap:
            self.title = "You had an average of \(average.toString(abbreviation: .intelligent, maxFractionDigits: 1)) restored purchases this week."
        }

        noData = false
    }

    private func showNoData() {
        let rawData = ACData.createExampleData(7)
        self.data = rawData
        self.average = rawData.isEmpty ? .infinity : rawData.map(\.0).reduce(0, +) / Float(rawData.count)
        self.max = rawData.map(\.0).max() ?? 1

        self.title = .placeholder(length: 55)

        noData = true
    }

    private var graph: some View {
        GeometryReader { val in
            HStack(alignment: .bottom) {
                Spacer()
                ForEach(data.reversed(), id: \.1) { (value, date) in
                    VStack {
                        RoundedRectangle(cornerRadius: 4)
                            .frame(width: val.size.width/20, height: abs(val.size.height * CGFloat(value/max) - 25))
                        Text(date.toString(format: "EEEEE")).unredacted()
                    }
                    .foregroundColor(.graphColor)
                }
            }
            .padding(.horizontal)
        }
    }

    private var line: some View {
        GeometryReader { val in
            Capsule()
                .foregroundColor(type.color)
                .frame(height: 6)
                .padding(.top, val.size.height - (val.size.height * CGFloat(average/max)) - 3)
                .overlay {
                    text
                        .padding(.top, val.size.height - (val.size.height * CGFloat(average/max)) + 8)
                }
        }
    }

    private var text: some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Avg. \(type.title)")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.graphColor)
                    .unredacted()

                UnitText(average.toString(abbreviation: .intelligent, maxFractionDigits: 1), infoType: type, currencySymbol: dataProvider.displayCurrencySymbol)
            }
            .padding(.leading, 10)
            Spacer()
        }
    }
}

struct WeeklyAverageCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CardSection {
                WeeklyAverageCard(type: .downloads, header: true)
                    .environmentObject(ACDataProvider.example)
                WeeklyAverageCard(type: .proceeds, header: true)
                    .environmentObject(ACDataProvider.exampleNoData)
            }
            .secondaryBackground()

            CardSection {
                WeeklyAverageCard(type: .downloads, header: true)
                    .environmentObject(ACDataProvider.example)
                WeeklyAverageCard(type: .proceeds, header: true)
                    .environmentObject(ACDataProvider.exampleNoData)
            }
            .secondaryBackground()
            .preferredColorScheme(.dark)
        }
    }
}
