//
//  InfoTile.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct InfoTile: View {
    private var description: LocalizedStringKey
    private var data: ACData
    private var rawData: [(Float, Date)]
    private var type: InfoType
    private var color: Color

    @State private var currentIndex: Int?
    private var graphData: [CGFloat] {
        let copy = rawData.map { $0.0 }
        let max: Float = copy.max() ?? 1
        return copy.map { CGFloat($0 / max) }
    }

    private var currencySymbol: String {
        switch type {
        case .proceeds:
            return data.displayCurrency.symbol
        default:
            return ""
        }
    }

    init(description: LocalizedStringKey, data: ACData, type: InfoType, color: Color = .accentColor) {
        self.description = description
        self.data = data
        self.rawData = data.getRawData(type, lastNDays: 30).reversed()
        self.type = type
        self.color = color
    }

    var body: some View {
        Card {
            topSection
            graphSection
                .frame(minHeight: 100)
            bottomSection
        }
        .frame(height: 250)
    }

    // MARK: Top
    var topSection: some View {
        HStack(alignment: .top) {
            if let index = currentIndex {
                Text(getGraphDataPoint(index).1.toString())
                    .font(.system(size: 20))
                Spacer()
                if currencySymbol.isEmpty {
                    UnitText(ACData.formatNumberLength(num: getGraphDataPoint(index).0, type: type), metricSymbol: type.systemImage)
                } else {
                    UnitText(ACData.formatNumberLength(num: getGraphDataPoint(index).0, type: type), metric: currencySymbol)
                }
            } else {
                Text(description)
                    .font(.system(size: 20))
                Spacer()
                if currencySymbol.isEmpty {
                    UnitText(data.getAsString(type, lastNDays: 1), metricSymbol: type.systemImage)
                } else {
                    UnitText(data.getAsString(type, lastNDays: 1), metric: currencySymbol)
                }
            }
        }
    }

    private func getGraphDataPoint(_ index: Int) -> (Float, Date) {
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
            if !graphData.isEmpty {
                GeometryReader { reading in
                    HStack(alignment: .bottom, spacing: 0) {
                        ForEach(graphData.indices) { i in
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
            } else {
                Text("NO_DATA")
                    .foregroundColor(.gray)
                    .italic()
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
            result = color
        } else if i < graphData.count && graphData[i] < 0 {
            result = .red
        }
        return result
    }

    // MARK: Bottom
    var bottomSection: some View {
        VStack {
            HStack(alignment: .bottom) {
                DescribedValueView(description: "LAST_SEVEN_DAYS", value: data.getAsString(type, lastNDays: 7, size: .compact).appending(currencySymbol))
                Spacer()
                    .frame(width: 40)
                DescribedValueView(description: "LAST_THIRTY_DAYS", value: data.getAsString(type, lastNDays: 30, size: .compact).appending(currencySymbol))
            }

            HStack(alignment: .bottom) {
                DescribedValueView(description: "CHANGE_PERCENT", value: data.getChange(type).appending("%"))
                Spacer()
                    .frame(width: 40)
                DescribedValueView(description: "MONTH_TO_DATE", value: data.getAsString(type, lastNDays: Date.dateToMonthNumber(), size: .compact).appending(currencySymbol))
            }
        }
    }
}

struct InfoTile_Previews: PreviewProvider {
    static var previews: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 320))], spacing: 8) {
            InfoTile(description: "DOWNLOADS", data: ACData.example, type: .downloads)
            InfoTile(description: "PROCEEDS", data: ACData.example, type: .proceeds)
        }.padding()
    }
}
