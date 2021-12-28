//
//  PercentStackedBarChart.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct PercentStackedBarChart: View {
    private var data: [(Float, Color)]
    private var dataSum: Float

    init(data: [(Float, Color)]) {
        self.data = data
        self.dataSum = data.reduce(0, { $0 + $1.0 })
    }

    var body: some View {
        if !data.isEmpty {
            GeometryReader { reading in
                HStack(spacing: 0) {
                    ForEach(data.indices) { i in
                        Rectangle()
                            .foregroundColor(data[i].1)
                            .frame(width: calcWidth(i: i, totalWidth: reading.size.width))
                    }
                }
                .clipShape(Capsule())
            }
        } else {
            Text("NO_DATA")
                .foregroundColor(.gray)
                .italic()
        }
    }

    private func calcWidth(i: Int, totalWidth: CGFloat) -> CGFloat {
        return CGFloat(data[i].0/dataSum) * totalWidth
    }
}

struct PercentStackedBarChart_Previews: PreviewProvider {
    static var previews: some View {
        PercentStackedBarChart(data: [(20, .accentColor), (15, .red), (25, .yellow), (10, .green)])
            .frame(height: 15)
            .padding()
    }
}
