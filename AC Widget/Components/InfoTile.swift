//
//  InfoTile.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import BetterToStrings

struct InfoTile: View {
    private var description: LocalizedStringKey
    private var data: ACData
    private var type: InfoType
    private var currencySymbol: String {
        switch type {
        case .proceeds:
            return data.displayCurrency.symbol
        default:
            return ""
        }
    }
    @State private var isFlipped: Bool = false
    @State private var interval: Int = 0
    private var lastNDays: Int {
        switch interval {
        case 1:
            return 7
        case 2:
            return 30
        case 3:
            return data.latestReportingDate().dateToMonthNumber()
        default:
            return 1
        }
    }

    init(description: LocalizedStringKey, data: ACData, type: InfoType) {
        self.description = description
        self.data = data
        self.type = type
    }
    var body: some View {
        Card {
            if isFlipped {
                backside
                    .rotation3DEffect(Angle(degrees: 180), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
            } else {
                InfoTileFront(description: description, data: data, type: type)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            self.isFlipped.toggle()
                        }
                    }
            }
        }
        .frame(height: 250)
        .rotation3DEffect(self.isFlipped ? Angle(degrees: 180): Angle(degrees: 0), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
        .frame(height: 250)
    }

    var backside: some View {
        VStack {
            Picker("SELECT_INTERVAL", selection: $interval) {
                Text("1D").tag(0)
                Text("7D").tag(1)
                Text("30D").tag(2)
                Text(Date.now.toString(format: "MMM")).tag(3)
            }
            .pickerStyle(.segmented)
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 8) {
                    ForEach(data.apps) { app in
                        appDetail(for: app)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    self.isFlipped.toggle()
                }
            }
        }
    }

    @ViewBuilder
    private func appDetail(for app: ACApp) -> some View {
        Card(alignment: .leading, spacing: 5, innerPadding: 10, color: .secondaryCardColor) {
            HStack(spacing: 4) {
                AsyncImage(url: URL(string: app.artworkUrl60)) { image in
                    image.resizable()
                } placeholder: {
                    Rectangle().foregroundColor(.secondary)
                }
                .frame(width: 15, height: 15)
                .cornerRadius(3)

                Text(app.name)
                    .lineLimit(1)
                Spacer()
            }

            if currencySymbol.isEmpty {
                UnitText(data.getAsString(type, lastNDays: lastNDays), metricSymbol: type.systemImage)
            } else {
                UnitText(data.getAsString(type, lastNDays: lastNDays), metric: currencySymbol)
            }
        }
    }
}

struct InfoTile_Previews: PreviewProvider {
    static var previews: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 320))], spacing: 8) {
            InfoTile(description: "PROCEEDS", data: ACData.example, type: .proceeds)
            InfoTile(description: "PROCEEDS", data: ACData.example, type: .proceeds)
                //.preferredColorScheme(.dark)
        }.padding()
    }
}
