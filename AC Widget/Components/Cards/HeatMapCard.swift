//
//  HeatMapCard.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct HeatMapCard: View {
    @EnvironmentObject private var dataProvider: ACDataProvider
    let type: InfoType
    let header: Bool
    @State private var rawData: [RawDataPoint] = []
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
                HeatMap(data: rawData, color: type.color)
                    .unredacted()
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
        self.rawData = acData.getRawData(for: type, lastNDays: 90)
        noData = false
    }

    private func showNoData() {
        self.rawData = ACData.createExampleData(90)
        noData = true
    }
}

struct HeatMapCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CardSection {
                HeatMapCard(type: .downloads, header: true)
                    .environmentObject(ACDataProvider.example)
                HeatMapCard(type: .proceeds, header: true)
                    .environmentObject(ACDataProvider.exampleNoData)
            }
            .secondaryBackground()

            CardSection {
                HeatMapCard(type: .downloads, header: true)
                    .environmentObject(ACDataProvider.example)
                HeatMapCard(type: .proceeds, header: true)
                    .environmentObject(ACDataProvider.exampleNoData)
            }
            .secondaryBackground()
            .preferredColorScheme(.dark)
        }
    }
}
