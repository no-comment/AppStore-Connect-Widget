//
//  CountryRankingCard.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct CountryRankingCard: View {
    @EnvironmentObject private var dataProvider: ACDataProvider
    let type: InfoType
    let header: Bool

    @State private var title: String = ""
    @State private var rankingData: [(String, Float)] = []

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
                RankingChart(data: rankingData, color: type.color, contrastColor: type.contrastColor)
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

        let countries = acData.getCountries(type, lastNDays: 30).map({ ($0.0.countryCodeToName(), $0.1) })

        guard !countries.isEmpty, !countries.allSatisfy({ $0.1 == 0 }) else {
            showNoData()
            return
        }

        if let max = countries.max(by: { return $0.1 < $1.1 }) {
            title = "\(max.0) has been your best country in the last 30 days."
        } else {
            title = ""
        }

        rankingData = countries
        noData = false
    }

    private func showNoData() {
        rankingData = [48, 42, 36, 28, 22, 5].map({ (String.placeholder(length: Int.random(in: 5...10)), $0) })
        self.title = .placeholder(length: 55).count.description
        noData = true
    }
}

struct CountryRankingCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CardSection {
                CountryRankingCard(type: .downloads, header: true)
                    .environmentObject(ACDataProvider.example)
                CountryRankingCard(type: .proceeds, header: true)
                    .environmentObject(ACDataProvider.exampleNoData)
            }
            .secondaryBackground()

            CardSection {
                CountryRankingCard(type: .downloads, header: true)
                    .environmentObject(ACDataProvider.example)
                CountryRankingCard(type: .proceeds, header: true)
                    .environmentObject(ACDataProvider.exampleNoData)
            }
            .secondaryBackground()
            .preferredColorScheme(.dark)
        }
    }
}
