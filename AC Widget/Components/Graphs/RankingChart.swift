//
//  RankingChart.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct RankingChart: View {
    let data: [(String, Float)]
    let color: Color
    let contrastColor: Color
    let maxValue: Float

    let spacing: CGFloat = 7
    let rowHeight: CGFloat = 30

    init(data: [(String, Float)], color: Color, contrastColor: Color) {
        self.color = color
        self.contrastColor = contrastColor
        self.data = data.sorted(by: \.1).reversed()
        self.maxValue = data.map(\.1).max() ?? 0
    }

    private func rowCount(_ maxHeight: CGFloat) -> Int {
        return Int(floor((maxHeight + spacing) / (rowHeight + spacing)))
    }

    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: spacing) {
                ForEach(data.prefix(rowCount(geo.size.height)).indices, id: \.self) { i in
                    RankingChartRow(data: data[i], color: i == 0 ? color : .graphColor, contrastColor: i == 0 ? contrastColor : .primary, width: maxValue == 0 ? 0 : geo.size.width * CGFloat(data[i].1 / maxValue))
                        .frame(height: rowHeight)
                }
            }
        }
    }
}

private struct RankingChartRow: View {
    let data: (String, Float)
    let color: Color
    let contrastColor: Color
    let width: CGFloat

    var body: some View {
        DynamicWidthChartRow(color: color, contrastColor: contrastColor, width: width) {
            Text(data.0 + " - " + data.1.toString(abbreviation: .intelligent, maxFractionDigits: 1))
                .fontWeight(.semibold)
        } longContent: {
            HStack {
                Text(data.0)
                    .fixedSize(horizontal: true, vertical: false)
                Spacer(minLength: 5)
                Text(data.1.toString(abbreviation: .intelligent, maxFractionDigits: 2))
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
    }
}

struct RankingChart_Previews: PreviewProvider {
    static var previews: some View {
        CardSection {
            RankingChart(data: [("Germany", 4800), ("United States", 4200), ("Australia", 3600), ("Mexico", 2800), ("Canada", 2200), ("Austria", 1378)], color: .accentColor, contrastColor: .white)
            //                .frame(height: 147)
            //                .border(.red)
        }
    }
}
