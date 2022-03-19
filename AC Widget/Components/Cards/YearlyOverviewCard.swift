//
//  YearlyOverviewCard.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct YearlyOverviewCard: View {
    @EnvironmentObject private var dataProvider: ACDataProvider
    private let type: InfoType
    private let header: Bool

    @State private var monthData: [(month: Int, val: Float)] = []
    @State private var maxData: (month: Int, val: Float) = (month: 0, val: 0)
    @State private var noData = true

    init(type: InfoType, header: Bool) {
        self.type = type
        self.header = header
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
                Text(Calendar.current.monthSymbols.indices.contains(maxData.month-1) ? "It looks like \(Calendar.current.monthSymbols[maxData.month-1]) is your strongest month." : "")
                    .font(.title2.weight(.semibold))

                Divider()
                graph
            }
            .noDataOverlay(noData)
        }
        .onAppear(perform: refresh)
        .onReceive(dataProvider.$data) { _ in refresh() }
    }

    private var graph: some View {
        GeometryReader { geo in
            HStack(alignment: .bottom) {
                ForEach(monthData, id: \.month) { (month: Int, val: Float) in
                    VStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(month == maxData.month ? type.color : .graphColor)
                            .frame(width: geo.size.width/20, height: maxData.val == 0 ? 0 : max(0, geo.size.height * CGFloat(val/maxData.val) - 25))

                        Text(Calendar.current.veryShortMonthSymbols[month-1]).unredacted()
                    }
                    .foregroundColor(.graphColor)
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func refresh() {
        guard let acData = dataProvider.data else {
            showNoData()
            return
        }
        let rawData = acData.getRawData(for: type, lastNDays: 365)

        guard !rawData.isEmpty else {
            showNoData()
            return
        }

        let currentMonth = Calendar.current.component(.month, from: .now)
        let monthOrder = Array(currentMonth...(currentMonth + 11)).map({ 1 + $0 % 12 })

        monthData = Dictionary(grouping: rawData) { (data) -> Int in
            return Calendar.current.component(.month, from: data.1)
        }.map { (key: Int, value: [RawDataPoint]) in
            (month: key, val: value.map(\.0).sum())
        }.sorted(by: {
            return (monthOrder.firstIndex(of: $0.month) ?? 13) < (monthOrder.firstIndex(of: $1.month) ?? 13)
        })

        if let max = monthData.max(by: { $0.val < $1.val }) {
            maxData = max
        }
        noData = false
    }

    private func showNoData() {
        let currentMonth = Calendar.current.component(.month, from: .now)
        let monthOrder = Array(currentMonth...(currentMonth + 11)).map({ 1 + $0 % 12 })

        monthData = monthOrder.map({ (month: $0, val: Float.random(in: 30...100)) })
        if let max = monthData.max(by: { $0.val < $1.val }) { maxData = max }

        noData = true
    }
}

struct YearlyOverviewCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CardSection {
                YearlyOverviewCard(type: .downloads, header: true)
                    .environmentObject(ACDataProvider.example)
                YearlyOverviewCard(type: .proceeds, header: true)
                    .environmentObject(ACDataProvider.exampleNoData)
            }
            .secondaryBackground()

            CardSection {
                YearlyOverviewCard(type: .downloads, header: true)
                    .environmentObject(ACDataProvider.example)
                YearlyOverviewCard(type: .proceeds, header: true)
                    .environmentObject(ACDataProvider.exampleNoData)
            }
            .secondaryBackground()
            .preferredColorScheme(.dark)
        }
    }
}
