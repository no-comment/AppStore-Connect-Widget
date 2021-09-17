//
//  DeviceTile.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct DeviceTile: View {
    private var data: ACData
    private var downloadData: [(String, Float)]
    private var proceedData: [(String, Float)]
    private var iapData: [(String, Float)]
    private var updateData: [(String, Float)]
    @State private var isFlipped: Bool = false

    init(data: ACData, colors: [Color] = [.accentColor, .red, .yellow, .green, .purple, .pink]) {
        self.data = data
        self.downloadData = data.getDevices(.downloads, lastNDays: 30).sorted(by: { $0.0 < $1.0 })
        self.proceedData = data.getDevices(.proceeds, lastNDays: 30).sorted(by: { $0.0 < $1.0 })
        self.updateData = data.getDevices(.updates, lastNDays: 30).sorted(by: { $0.0 < $1.0 })
        self.iapData = data.getDevices(.iap, lastNDays: 30).sorted(by: { $0.0 < $1.0 })
    }

    var body: some View {
        Card(alignment: .leading, spacing: 7) {
            if isFlipped {
                backSide
                 .rotation3DEffect(Angle(degrees: 180), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
            } else {
                Text("DEVICES")
                    .font(.system(size: 20))
                charts
                Spacer(minLength: 0)
                legend
            }
        }
        .frame(height: 250)
        .rotation3DEffect(self.isFlipped ? Angle(degrees: 180): Angle(degrees: 0), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
        .onTapGesture {
            withAnimation {
                self.isFlipped.toggle()
            }
        }
    }

    var charts: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("DOWNLOADS")
            PercentStackedBarChart(data: downloadData.map({ ($0.1, ACDevice($0.0).color) }))
                .frame(height: 10)

            Text("PROCEEDS")
            PercentStackedBarChart(data: proceedData.map({ ($0.1, ACDevice($0.0).color) }))
                .frame(height: 10)

            Text("IN-APP-PURCHASES")
            PercentStackedBarChart(data: iapData.map({ ($0.1, ACDevice($0.0).color) }))
                .frame(height: 10)

            Text("UPDATES")
            PercentStackedBarChart(data: updateData.map({ ($0.1, ACDevice($0.0).color) }))
                .frame(height: 10)
        }
        .font(.system(size: 15))
    }

    var backSide: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                ForEach(data.apps) { app in
                    appDetail(for: app)
                }
            }
            legend
        }
    }

    @ViewBuilder
    private func appDetail(for app: ACApp) -> some View {
        Card(alignment: .leading, spacing: 5, innerPadding: 10, color: .secondaryCardColor) {
            HStack(spacing: 4) {
                Group {
                    if let data = app.artwork60ImgData, let uiImg = UIImage(data: data) {
                        Image(uiImage: uiImg)
                            .resizable()
                    } else {
                        Rectangle().foregroundColor(.secondary)
                    }
                }
                .frame(width: 15, height: 15)
                .cornerRadius(4)

                Text(app.name)
                    .lineLimit(1)
                Spacer()
            }
            Group {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                        .foregroundColor(.gray)
                    PercentStackedBarChart(data:
                                            data.getDevices(.downloads, lastNDays: 30, filteredApps: [app])
                                            .sorted(by: { $0.0 < $1.0 })
                                            .map({ ($0.1, ACDevice($0.0).color) })
                    )
                        .frame(height: 7)
                }
                HStack {
                    ZStack {
                        Image(systemName: "circle.fill")
                            .foregroundColor(.secondaryCardColor)
                    Text(data.displayCurrency.symbol)
                        .foregroundColor(.gray)
                    }
                    PercentStackedBarChart(data:
                                            data.getDevices(.proceeds, lastNDays: 30, filteredApps: [app])
                                            .sorted(by: { $0.0 < $1.0 })
                                            .map({ ($0.1, ACDevice($0.0).color) })
                    )
                        .frame(height: 7)
                }
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundColor(.gray)
                    PercentStackedBarChart(data:
                                            data.getDevices(.updates, lastNDays: 30, filteredApps: [app])
                                            .sorted(by: { $0.0 < $1.0 })
                                            .map({ ($0.1, ACDevice($0.0).color) })
                    )
                        .frame(height: 7)
                }
            }
            .font(.system(size: 12))
        }
    }

    var legend: some View {
        HStack {
            Spacer()
            ForEach(ACDevice.allCases) { device in
                ZStack {
                    Circle()
                        .foregroundColor(device.color)
                        .frame(width: 30, height: 30)
                    Image(systemName: device.symbol)
                        .font(.system(size: 16, weight: .bold))
                }
                Spacer()
            }
        }
    }
}

struct DeviceTile_Previews: PreviewProvider {
    static var previews: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 320))], spacing: 8) {
            DeviceTile(data: ACData.example)
                .preferredColorScheme(.dark)
        }.padding()
    }
}
