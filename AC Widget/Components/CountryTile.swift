//
//  CountryTile.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct CountryTile: View {
    private var data: ACData
    private var color: Color

    init(data: ACData, color: Color = .accentColor) {
        self.data = data
        self.color = color
    }

    var body: some View {
        Card {
            HStack {
                Text("TOP_COUNTRIES")
                    .font(.system(size: 20))
                Spacer()
            }
            .padding(.bottom, 5)

            ForEach(0..<7) { i in
                DescribedValueView(description: countryName(placement: i), value: countryProceeds(placement: i))
            }
            Spacer()
        }
        .frame(height: 250)
    }

    private func countryName(placement: Int) -> LocalizedStringKey {
        let countries = data.getCountries(.proceeds, lastNDays: 30).sorted(by: { $0.1 > $1.1 })
        if placement < countries.count {
            return LocalizedStringKey(countries[placement].0.countryCodeToName())
        }
        return ""
    }

    private func countryProceeds(placement: Int) -> String {
        let countries = data.getCountries(.proceeds, lastNDays: 30).sorted(by: { $0.1 > $1.1 })
        if placement < countries.count {
            let nf = NumberFormatter()
            nf.numberStyle = .decimal
            nf.maximumFractionDigits = 1
            let number = NSNumber(value: countries[placement].1)
            if let string = nf.string(from: number) {
                return string.appending(data.displayCurrency.symbol)
            }
        }
        return ""
    }
}

struct CountryTile_Previews: PreviewProvider {
    static var previews: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 320))], spacing: 8) {
            CountryTile(data: ACData.example)
        }.padding()
    }
}
