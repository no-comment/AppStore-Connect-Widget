//
//  GraphView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import WidgetKit

struct GraphView: View {
    let data: [CGFloat]
    let color: Color

    init(_ data: [(Float, Date)], color: Color = .accentColor) {
        let copy = data.map { $0.0 }
        let max: Float = copy.max() ?? 1
        self.data = copy.map { CGFloat($0 / max) }.reversed()
        self.color = color
    }

    var body: some View {
        if !data.isEmpty {
            GeometryReader { reading in
                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(data.indices) { i in
                        Capsule()
                            .frame(width: (reading.size.width/CGFloat(data.count))*0.7, height: reading.size.height * getHeight(i))
                            .foregroundColor(getColor(i))

                        if i != data.count-1 {
                            Spacer()
                                .frame(minWidth: 0)
                        }
                    }
                }
            }
        } else {
            Text("NO_DATA")
                .foregroundColor(.gray)
                .italic()
        }
    }

    private func getHeight(_ i: Int) -> CGFloat {
        if i < data.count && data[i] > 0 {
            return data[i]
        }
        if i < data.count && data[i] < 0 {
            return abs(data[i])
        }
        return 0.01
    }

    private func getColor(_ i: Int) -> Color {
        if i < data.count && data[i] > 0 {
            return color
        }
        if i < data.count && data[i] < 0 {
            return .red
        }
        return .gray
    }
}

struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GraphView(ACData.example.getRawData(.downloads, lastNDays: 30), color: .pink)
                .padding()
                .previewContext(WidgetPreviewContext(family: .systemSmall))

            GraphView(ACData.example.getRawData(.proceeds, lastNDays: 30))
                .padding()
                .previewContext(WidgetPreviewContext(family: .systemSmall))

            GraphView([(Float, Date)]())
                .padding()
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
