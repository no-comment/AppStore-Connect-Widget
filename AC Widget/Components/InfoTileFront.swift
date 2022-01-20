//
//  InfoTileFront.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import BetterToStrings

struct InfoTileFront: View {
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
        self.rawData = data.getRawData(for: type, lastNDays: 30).reversed()
        self.type = type
        self.color = color
    }

    var body: some View {
        VStack {
            // Temporarily disabled update numbers (GitHub Issue #3)
            if type == .updates {
                HStack {
                    Text(description)
                    Spacer()
                    Image(systemName: InfoType.updates.systemImage)
                }
                .font(.system(size: 20))
                .padding(.bottom, 20)
            } else {
                topSection
            }
            graphSection
                .frame(minHeight: 100)
            if type != .updates {
                bottomSection
            }
        }
    }

    // MARK: Top
    var topSection: some View {
        HStack(alignment: .top) {
            if let index = currentIndex {
                Text(getGraphDataPoint(index).1.toString(format: "dd. MMM.", smartConversion: true))
                    .font(.system(size: 20))
                Spacer()
                if currencySymbol.isEmpty {
                    UnitText(getGraphDataPoint(index).0.toString(abbreviation: .intelligent, maxFractionDigits: 2), metricSymbol: type.systemImage)
                } else {
                    UnitText(getGraphDataPoint(index).0.toString(abbreviation: .intelligent, maxFractionDigits: 2), metric: currencySymbol)
                }
            } else {
                Text(description)
                    .font(.system(size: 20))
                Spacer()
                if currencySymbol.isEmpty {
                    UnitText(data.getRawData(for: type, lastNDays: 1).toString(), metricSymbol: type.systemImage)
                } else {
                    UnitText(data.getRawData(for: type, lastNDays: 1).toString(), metric: currencySymbol)
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
                DescribedValueView(description: "LAST_SEVEN_DAYS", value: data.getRawData(for: type, lastNDays: 7).toString(size: .compact).appending(currencySymbol))
                Spacer()
                    .frame(width: 40)
                DescribedValueView(description: "LAST_THIRTY_DAYS", value: data.getRawData(for: type, lastNDays: 30).toString(size: .compact).appending(currencySymbol))
            }

            HStack(alignment: .bottom) {
                DescribedValueView(description: "CHANGE_PERCENT", value: data.getChange(type).appending("%"))
                Spacer()
                    .frame(width: 40)
                DescribedValueView(descriptionString: data.latestReportingDate().toString(format: "MMMM").appending(":"),
                                   value: data.getRawData(for: type, lastNDays: data.latestReportingDate().dateToMonthNumber()).toString(size: .compact).appending(currencySymbol))
            }
        }
    }
}

struct InfoTileFront_Previews: PreviewProvider {
    static var previews: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 320))], spacing: 8) {
            Card {
                InfoTileFront(description: "DOWNLOADS", data: ACData.example, type: .downloads)
            }
            .frame(height: 250)
            Card {
                InfoTileFront(description: "PROCEEDS", data: ACData.example, type: .proceeds)
            }
            .frame(height: 250)
            Card {
                InfoTileFront(description: "UPDATES", data: ACData.example, type: .updates)
            }
            .frame(height: 250)
        }.padding()
    }
}
