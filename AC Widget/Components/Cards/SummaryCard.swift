//
//  SummaryCard.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct SummaryCard: View {
    @EnvironmentObject private var dataProvider: ACDataProvider
    private let type: InfoType
    private let header: Bool

    @State private var currentIndex: Int?
    @State private var graphData: [CGFloat] = []

    @State private var latestData: RawDataPoint = (0, .now)
    @State private var rawData: [RawDataPoint] = []

    @State private var sevenDays: String = ""
    @State private var thirtyDays: String = ""
    @State private var change: String = ""
    @State private var month: String = ""

    @State private var noData = true

    init(type: InfoType, header: Bool) {
        self.type = type
        self.header = header

        //        rawData = data.getRawData(for: type, lastNDays: 30)
        //        let copy = rawData.map { $0.0 }
        //        let max: Float = copy.max() ?? 1
        //        graphData = copy.map { CGFloat($0 / max) }
    }

    //    private var data: ACData
    //    private var rawData: [RawDataPoint]
    //    private var graphData: [CGFloat]
    //
    //    private var currencySymbol: String {
    //        switch type {
    //        case .proceeds:
    //            return data.displayCurrency.symbol
    //        default:
    //            return ""
    //        }
    //    }
    //
    //    let type: InfoType
    //    let header: Bool

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                if header {
                    Label(type.title, systemImage: type.systemImage)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(type.color)
                        .unredacted()
                }
                topSection
                graphSection
                bottomSection
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
        rawData = acData.getRawData(for: type, lastNDays: 30).reversed()

        guard !rawData.isEmpty else {
            showNoData()
            return
        }

        let copy = rawData.map { $0.0 }
        let max: Float = copy.max() ?? 1
        graphData = copy.map { CGFloat($0 / max) }

        latestData = rawData.last ?? (0, .now)

        var suffix = ""
        if type == .proceeds {
            suffix = dataProvider.displayCurrencySymbol
        }

        sevenDays = Array(rawData.prefix(7)).toString(size: .compact).appending(suffix)
        thirtyDays = rawData.toString(size: .compact).appending(suffix)
        change = dataProvider.data?.getChange(type).appending("%") ?? "-"
        month = acData.getRawData(for: type, lastNDays: latestData.1.dateToDayNumber()).toString(size: .compact).appending(suffix)

        noData = false
    }

    private func showNoData() {
        rawData = ACData.createExampleData(30)
        let copy = rawData.map { $0.0 }
        let max: Float = copy.max() ?? 1
        graphData = copy.map { CGFloat($0 / max) }

        latestData = rawData.last ?? (0, .now)

        noData = true
    }

    var currencySymbol: String {
        dataProvider.displayCurrencySymbol
    }

    // MARK: Top
    var topSection: some View {
        HStack(alignment: .top) {
            if let index = currentIndex {
                Text(getGraphDataPoint(index).1.reportingDate())
                    .font(.system(size: 20))
                Spacer()
                UnitText(getGraphDataPoint(index).0.toString(abbreviation: .intelligent, maxFractionDigits: 2), infoType: type, currencySymbol: currencySymbol)
            } else {
                Text(latestData.1.reportingDate())
                    .font(.system(size: 20))
                Spacer()
                UnitText([latestData].toString(), infoType: type, currencySymbol: currencySymbol)
            }
        }
    }

    private func getGraphDataPoint(_ index: Int) -> RawDataPoint {
        if index >= rawData.count {
            return rawData.last ?? (0, Date(timeIntervalSince1970: 0))
        }
        if index < 0 {
            return rawData.first ?? (0, Date(timeIntervalSince1970: 0))
        }
        return rawData[index]
    }

    // MARK: Graph
    var graphSection: some View {
        Group {
            GeometryReader { reading in
                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(graphData.indices, id: \.self) { i in
                        Capsule()
                            .frame(width: (reading.size.width/CGFloat(graphData.count))*0.7, height: reading.size.height * getGraphHeight(i))
                            .foregroundColor(getGraphColor(i))
                            .opacity(currentIndex == i ? 0.7 : 1)

                        if i != graphData.count-1 {
                            Spacer()
                                .frame(minWidth: 0)
                        }
                    }
                }
                .contentShape(Rectangle())
                .highPriorityGesture(DragGesture(minimumDistance: 20)
                    .onChanged({ value in
                        let newIndex = Int((value.location.x/reading.size.width) * CGFloat(graphData.count))
                        if newIndex != currentIndex && newIndex < rawData.count && newIndex >= 0 {
                            currentIndex = newIndex
                            UISelectionFeedbackGenerator()
                                .selectionChanged()
                        }
                    })
                        .onEnded({ _ in
                            withAnimation(Animation.easeOut(duration: 0.2)) {
                                currentIndex = nil
                            }
                        })
                )
            }
        }
    }

    private func getGraphHeight(_ i: Int) -> CGFloat {
        if i < graphData.count && graphData[i] > 0 {
            return graphData[i]
        }
        if i < graphData.count && graphData[i] < 0 {
            return abs(graphData[i])
        }
        return 0.01
    }

    private func getGraphColor(_ i: Int) -> Color {
        var result: Color = .gray
        if i < graphData.count && graphData[i] > 0 {
            result = type.color
        } else if i < graphData.count && graphData[i] < 0 {
            result = .red
        }
        return result
    }

    // MARK: Bottom
    var bottomSection: some View {
        VStack {
            HStack(alignment: .bottom) {
                DescribedValueView(description: "7 days:", value: sevenDays)
                Spacer()
                    .frame(width: 40)
                DescribedValueView(description: "30 days:", value: thirtyDays)
            }

            HStack(alignment: .bottom) {
                DescribedValueView(description: "Change:", value: change)
                Spacer()
                    .frame(width: 40)
                DescribedValueView(descriptionString: latestData.1.toString(format: "MMMM").appending(":"), value: month)
            }
        }
    }
}

struct SummaryCard_Previews: PreviewProvider {
    static var previews: some View {
        CardSection {
            SummaryCard(type: .downloads, header: false)
                .environmentObject(ACDataProvider.example)
            SummaryCard(type: .proceeds, header: true)
                .environmentObject(ACDataProvider.exampleNoData)
        }
        .secondaryBackground()
    }
}
