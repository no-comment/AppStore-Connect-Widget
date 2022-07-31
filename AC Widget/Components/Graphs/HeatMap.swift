//
//  HeatMap.swift
//  AC Widget by NO-COMMENT
//

import BetterToStrings
import SwiftUI

struct HeatMap: View {
    private static let size: CGFloat = 20
    private static let spacing: CGFloat = 5
    private static let rows: [GridItem] = .init(repeating: .init(.fixed(size), spacing: spacing), count: 7)

    let data: [RawDataPoint]
    let color: Color
    let maxValue: Float
    let latestDate: Date

    init(data: [RawDataPoint], color: Color = .accentColor) {
        self.color = color
        self.data = data
        self.maxValue = data.max(by: { $0.value < $1.value })?.value ?? 1
        self.latestDate = data.max(by: { $0.date < $1.date })?.date ?? Date.now
    }

    var body: some View {
        GeometryReader { reading in
            let numOfBoxes = abs(numOfBoxes(width: reading.size.width))

            LazyHGrid(rows: HeatMap.rows, spacing: HeatMap.spacing) {
                ForEach(0 ..< numOfBoxes, id: \.self) { index in
                    Group {
                        if index < 7 {
                            weekdayLabel(index: index)
                        } else {
                            element(date: latestDate.addingTimeInterval(-86400 * Double((numOfBoxes - 1) - index)))
                        }
                    }
                }
            }
        }
        .frame(maxHeight: 7 * HeatMap.size + 6 * HeatMap.spacing)
    }

    private func numOfBoxes(width: CGFloat) -> Int {
        let weekday = Calendar.current.component(.weekday, from: Date.now) + 1
        return (Int((width + HeatMap.spacing) / (HeatMap.size + HeatMap.spacing)) * 7) - weekday
    }

    private func weekdayLabel(index: Int) -> some View {
        Text(DateFormatter().veryShortWeekdaySymbols[(index + 1) % 7])
            .frame(width: HeatMap.size, height: HeatMap.size)
            .font(.body.weight(.medium))
            .foregroundColor(.gray)
    }

    private func element(date: Date) -> some View {
        if let dataPoint = data.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            if dataPoint.value == 0 {
                return RoundedRectangle(cornerRadius: 5)
                    .frame(width: HeatMap.size, height: HeatMap.size)
                    .foregroundColor(.graphColor)
            }
            return RoundedRectangle(cornerRadius: 5)
                .frame(width: HeatMap.size, height: HeatMap.size)
                .foregroundColor(color.opacity(max(Double(dataPoint.value / maxValue), 0.08)))
        }
        return RoundedRectangle(cornerRadius: 5)
            .frame(width: HeatMap.size, height: HeatMap.size)
            .foregroundColor(.graphColor)
    }
}

struct HeatMap_Previews: PreviewProvider {
    static var previews: some View {
        HeatMap(data: ACData.example.getRawData(for: .downloads, lastNDays: 60),
                color: InfoType.downloads.color)
            .padding()
    }
}
