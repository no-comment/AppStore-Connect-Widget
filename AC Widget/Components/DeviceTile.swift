//
//  DeviceTile.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct DeviceTile: View {
    private var downloadData: [(String, Float)]
    private var proceedData: [(String, Float)]
    private var updateData: [(String, Float)]
    private var legendPairs: [String: Color]

    init(data: ACData, colors: [Color] = [.accentColor, .red, .yellow, .green, .purple, .pink]) {
        self.downloadData = data.getDevices(.downloads, lastNDays: 30).sorted(by: { $0.0 < $1.0 })
        self.proceedData = data.getDevices(.proceeds, lastNDays: 30).sorted(by: { $0.0 < $1.0 })
        self.updateData = data.getDevices(.updates, lastNDays: 30).sorted(by: { $0.0 < $1.0 })

        let allDevices: [String] = downloadData.map({ $0.0 })
            + proceedData.map({ $0.0 })
            + updateData.map({ $0.0 })

        var i = 0
        var deviceLegend: [String: Color] = [:]
        for device in Set(allDevices) {
            deviceLegend[device] = colors[i % colors.count]
            i += 1
        }
        self.legendPairs = deviceLegend
    }

    var body: some View {
        Card(alignment: .leading, spacing: 7) {
            Text("DEVICES")
                .font(.system(size: 20))
            charts
            Spacer(minLength: 0)
            legend
        }
        .frame(height: 250)
    }

    var charts: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("DOWNLOADS")
            PercentStackedBarChart(data: downloadData.map({ ($0.1, legendPairs[$0.0] ?? .gray) }))
                .frame(height: 10)

            Text("PROCEEDS")
            PercentStackedBarChart(data: proceedData.map({ ($0.1, legendPairs[$0.0] ?? .gray) }))
                .frame(height: 10)

            Text("UPDATES")
            PercentStackedBarChart(data: updateData.map({ ($0.1, legendPairs[$0.0] ?? .gray) }))
                .frame(height: 10)
        }
    }

    var legend: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 4) {
            ForEach(Array(legendPairs.keys).sorted(by: <), id: \.self) { key in
                HStack {
                    Image(systemName: "circle.fill")
                        .foregroundColor(legendPairs[key] ?? .gray)
                    Text(key)
                    Spacer()
                }
            }
        }
    }
}

struct DeviceTile_Previews: PreviewProvider {
    static var previews: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 320))], spacing: 8) {
            DeviceTile(data: ACData.example)
        }.padding()
    }
}
