//
//  ComparisonCard.swift
//  AC Widget by NO-COMMENT
//

import BetterToStrings
import SwiftUI

struct ComparisonCard: View {
    @EnvironmentObject private var dataProvider: ACDataProvider
    let type: InfoType
    let header: Bool
    let interval: TimeIntervall
    @State private var title: String = ""
    @State private var primaryValue: Float = 0
    @State private var primaryLabel: String = ""
    @State private var secondaryValue: Float = 0
    @State private var secondaryLabel: String = ""

    @State private var noData = true

    let rowHeight: CGFloat = 30

    private var maxValue: Float {
        max(primaryValue, secondaryValue)
    }

    var body: some View {
        Card {
            GeometryReader { geo in
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

                    VStack(alignment: .leading, spacing: 1) {
                        UnitText(primaryValue.toString(abbreviation: .intelligent, maxFractionDigits: 2), infoType: type, currencySymbol: dataProvider.displayCurrencySymbol)
                        DynamicWidthChartRow(color: type.color, contrastColor: type.contrastColor, width: maxValue == 0 ? 0 : geo.size.width * CGFloat(primaryValue / maxValue)) {
                            Text(primaryLabel)
                                .font(.system(size: 15, weight: .medium))
                                .unredacted()
                        } longContent: {
                            Text(primaryLabel)
                                .font(.system(size: 15, weight: .medium))
                                .unredacted()
                        }
                        .frame(height: rowHeight)
                    }
                    Spacer(minLength: 0)
                    VStack(alignment: .leading, spacing: 1) {
                        UnitText(secondaryValue.toString(abbreviation: .intelligent, maxFractionDigits: 2), infoType: type, currencySymbol: dataProvider.displayCurrencySymbol)

                        DynamicWidthChartRow(color: .graphColor, contrastColor: .primary, width: maxValue == 0 ? 0 : geo.size.width * CGFloat(secondaryValue / maxValue)) {
                            Text(secondaryLabel)
                                .font(.system(size: 15, weight: .medium))
                                .unredacted()
                        } longContent: {
                            Text(secondaryLabel)
                                .font(.system(size: 15, weight: .medium))
                                .unredacted()
                        }
                        .frame(height: rowHeight)
                    }
                }
            }
            .noDataOverlay(noData)
        }
        .onLoad(perform: refresh)
        .onReceive(dataProvider.$data) { _ in refresh() }
    }

    private func refresh() {
        guard let acData = dataProvider.data else {
            showNoData()
            return
        }

        self.primaryValue = acData.getRawData(for: type, lastNDays: interval.lastNDays).reduce(0, { $0 + $1.value })
        self.secondaryValue = acData.getRawData(for: type, lastNDays: 2 * interval.lastNDays).reduce(0, { $0 + $1.value }) - primaryValue

        guard primaryValue != 0 || secondaryValue != 0 else {
            showNoData()
            return
        }

        self.primaryLabel = interval.primaryLabel
        self.secondaryLabel = interval.secondaryLabel

        switch type {
        case .downloads, .updates, .restoredIap, .reDownloads, .iap:
            if primaryValue == secondaryValue {
                self.title = "Your average \(type.title.lowercased()) in the last \(interval.sentenceBlock) were the same as before."
            } else if primaryValue < secondaryValue {
                self.title = "You had more \(type.title.lowercased()) in the last \(interval.sentenceBlock) than before."
            } else {
                self.title = "You had less \(type.title.lowercased()) in the last \(interval.sentenceBlock) than before."
            }
        case .proceeds:
            if primaryValue == secondaryValue {
                self.title = "Your earnings in the last \(interval.sentenceBlock) did not change."
            } else if primaryValue < secondaryValue {
                self.title = "You earned more in the last \(interval.sentenceBlock) than before."
            } else {
                self.title = "You earned less in the last \(interval.sentenceBlock) than before."
            }
        }

        noData = false
    }

    private func showNoData() {
        self.primaryValue = 42
        self.secondaryValue = 69 - primaryValue
        self.primaryLabel = interval.primaryLabel
        self.secondaryLabel = interval.secondaryLabel
        self.title = .placeholder(length: 40)
        noData = true
    }
}

struct ComparisonCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CardSection {
                ComparisonCard(type: .downloads, header: true, interval: .sevenDays)
                    .environmentObject(ACDataProvider.example)
                ComparisonCard(type: .proceeds, header: true, interval: .thirtyDays)
                    .environmentObject(ACDataProvider.exampleNoData)
            }
            .secondaryBackground()

            CardSection {
                ComparisonCard(type: .downloads, header: true, interval: .sevenDays)
                    .environmentObject(ACDataProvider.example)
                ComparisonCard(type: .proceeds, header: true, interval: .thirtyDays)
                    .environmentObject(ACDataProvider.exampleNoData)
            }
            .secondaryBackground()
            .preferredColorScheme(.dark)
        }
    }
}

enum TimeIntervall {
    case thirtyDays, sevenDays
    // case lastMonth, lastWeek
    // case quarter, semester, year

    var lastNDays: Int {
        switch self {
        case .thirtyDays:
            return 30
        case .sevenDays:
            return 7
        }
    }

    var primaryLabel: String {
        switch self {
        case .thirtyDays:
            return "Last 30 days"
        case .sevenDays:
            return "Last 7 days"
        }
    }

    var secondaryLabel: String {
        switch self {
        case .thirtyDays:
            return "Previous 30 days"
        case .sevenDays:
            return "Previous 7 days"
        }
    }

    var sentenceBlock: String {
        switch self {
        case .thirtyDays:
            return "30 days"
        case .sevenDays:
            return "7 days"
        }
    }
}
