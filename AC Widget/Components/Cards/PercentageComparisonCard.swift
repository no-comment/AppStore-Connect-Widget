//
//  PercentageComparisonCard.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import BetterToStrings

struct PercentageComparisonCard: View {
    @EnvironmentObject private var dataProvider: ACDataProvider
    let type: InfoType
    let header: Bool
    @State private var title: String = ""
    @State private var mainValue: Float = 1
    @State private var comparisonValue: Float = 1

    @State private var noData = true

    var comparisonType: InfoType {
        switch type {
        case .reDownloads:
            return .downloads
        case .restoredIap:
            return .iap
        default:
            return .downloads
        }
    }

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

                VStack(spacing: 6) {
                    HStack {
                        Text(comparisonType.title)
                            .foregroundColor(comparisonType.color)
                        Spacer()
                        Text(type.title)
                            .foregroundColor(type.color)
                    }
                    .font(.caption.weight(.medium))
                    .unredacted()

                    HStack {
                        Text(comparisonValue.toString(abbreviation: .intelligent))
                        Spacer()
                        Text(mainValue.toString(abbreviation: .intelligent))
                    }
                    .font(.system(size: 34, weight: .semibold, design: .rounded))

                    GeometryReader { val in
                        HStack(spacing: 5) {
                            Rectangle()
                                .foregroundColor(comparisonType.color)
                                .frame(width: abs(val.size.width-5)*CGFloat(comparisonValue/(mainValue + comparisonValue)))

                            Rectangle()
                                .foregroundColor(type.color)
                                .frame(width: abs(val.size.width-5)*CGFloat(mainValue/(mainValue + comparisonValue)))
                        }
                        .clipShape(Capsule())
                    }
                    .frame(height: 16)
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

        self.mainValue = acData.getRawData(for: type, lastNDays: 30).reduce(0, { $0 + $1.0 })
        self.comparisonValue = acData.getRawData(for: comparisonType, lastNDays: 30).reduce(0, { $0 + $1.0 })

        guard mainValue != 0 || comparisonValue != 0 else {
            showNoData()
            return
        }

        if mainValue == 0 && comparisonValue == 0 { return } // check if division by zero
        let percentage = (mainValue / (mainValue + comparisonValue))*100

        switch type {
        case .reDownloads:
            self.title = "\(percentage.toString(abbreviation: .none, maxFractionDigits: 1))% of your total downloads were re-downloaded."
        case .restoredIap:
            self.title = "\(percentage.toString(abbreviation: .none, maxFractionDigits: 1))% of your total in-app purchases were restored."
        default:
            self.title = "ERROR"
        }

        noData = false
    }

    private func showNoData() {
        self.mainValue = Float(Int.random(in: 50...100))
        self.comparisonValue = Float(Int.random(in: 20...60))

        self.title = .placeholder(length: 50)

        noData = true
    }
}

struct PercentageComparisonCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CardSection {
                PercentageComparisonCard(type: .reDownloads, header: true)
                    .environmentObject(ACDataProvider.example)
                PercentageComparisonCard(type: .restoredIap, header: true)
                    .environmentObject(ACDataProvider.exampleNoData)
            }
            .secondaryBackground()

            CardSection {
                PercentageComparisonCard(type: .reDownloads, header: true)
                    .environmentObject(ACDataProvider.example)
                PercentageComparisonCard(type: .restoredIap, header: true)
                    .environmentObject(ACDataProvider.exampleNoData)
            }
            .secondaryBackground()
            .preferredColorScheme(.dark)
        }
    }
}
