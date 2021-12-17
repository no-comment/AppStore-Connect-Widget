//
//  CurrencyPicker.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct CurrencyPicker: View {
    @Binding var selection: String

    @State private var searchQuery: String = ""

    var currencies: [Currency] {
        let search = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if search.isEmpty { return Currency.sortedAllCases }
        return Currency.sortedAllCases
            .filter { currency in
                return currency.rawValue.localizedCaseInsensitiveContains(search)
                || currency.symbol.localizedCaseInsensitiveContains(search)
                || currency.name.localizedCaseInsensitiveContains(search)
            }
    }

    var body: some View {
        Form {
            List {
                ForEach(currencies, id: \.rawValue) { currency in
                    Button(action: {
                        selection = currency.rawValue
                    }) {
                        HStack {
                            Text(currency.name)
                            Spacer()
                            CurrencySymbol(symbol: currency.symbol)
                                .foregroundColor(currency.rawValue == selection ? .accentColor : .primary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle(Text("APP_CURRENCY"))
        }
        .searchable(text: $searchQuery, placement: .navigationBarDrawer(displayMode: .always))
    }
}

struct CurrencyPicker_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyPicker(selection: .constant(""))
    }
}
