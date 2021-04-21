//
//  CurrencyConverter.swift
//  AC Widget by NO-COMMENT
//

import Foundation
import Promises

//
//  CurrencyConverter.swift
//  Created by Thiago Martins on 26/03/19.
//

// Global Enumerations:
enum Currency: String, CaseIterable, Codable {
    case AUD; case INR; case TRY
    case BGN; case ISK; case USD
    case BRL; case JPY; case ZAR
    case CAD; case KRW
    case CHF; case MXN
    case CNY; case MYR
    case CZK; case NOK
    case DKK; case NZD
    case EUR; case PHP
    case GBP; case PLN
    case HKD; case RON
    case HRK; case RUB
    case HUF; case SEK
    case IDR; case SGD
    case ILS; case THB

    var symbol: String {
        return getSymbolForCurrencyCode(code: self.rawValue)
    }

    func getSymbolForCurrencyCode(code: String) -> String {
        var candidates: [String] = []
        let locales: [String] = NSLocale.availableLocaleIdentifiers
        for localeID in locales {
            guard let symbol = findMatchingSymbol(localeID: localeID, currencyCode: code) else {
                continue
            }
            if symbol.count == 1 {
                return symbol
            }
            candidates.append(symbol)
        }
        let sorted = sortAscByLength(list: candidates)
        if sorted.count < 1 {
            return ""
        }
        return sorted[0]
    }

    func findMatchingSymbol(localeID: String, currencyCode: String) -> String? {
        let locale = Locale(identifier: localeID as String)
        guard let code = locale.currencyCode else {
            return nil
        }
        if code != currencyCode {
            return nil
        }
        guard let symbol = locale.currencySymbol else {
            return nil
        }
        return symbol
    }

    func sortAscByLength(list: [String]) -> [String] {
        return list.sorted(by: { $0.count < $1.count })
    }
}

// Global Classes:
class CurrencyConverter {

    static let shared = CurrencyConverter()

    private var exchangeRates: [Currency: Double] = [
        .EUR: 1.0,
        .USD: 1.1321,
        .JPY: 126.76,
        .BGN: 1.9558,
        .CZK: 25.623,
        .DKK: 7.4643,
        .GBP: 0.86290,
        .HUF: 321.90,
        .PLN: 4.2796,
        .RON: 4.7598,
        .SEK: 10.4788,
        .CHF: 1.1326,
        .ISK: 135.20,
        .NOK: 9.6020,
        .HRK: 7.4350,
        .RUB: 72.6133,
        .TRY: 6.5350,
        .AUD: 1.5771,
        .BRL: 4.3884,
        .CAD: 1.5082,
        .CNY: 7.5939,
        .HKD: 8.8788,
        .IDR: 15954.12,
        .ILS: 4.0389,
        .INR: 78.2915,
        .KRW: 1283.00,
        .MXN: 21.2360,
        .MYR: 4.6580,
        .NZD: 1.6748,
        .PHP: 58.553,
        .SGD: 1.5318,
        .THB: 35.955,
        .ZAR: 15.7631,
    ]

    // Private Properties:
    //    private var exchangeRates : [Currency : Double] = [:]
    private let xmlParser = CurrencyXMLParser()

    init() { }

    // Public Methods:
    /** Updates the exchange rate and runs the completion afterwards. */
    public func updateExchangeRates() -> Promise<Any?> {
        return wrap { completion in
            self.xmlParser.parse(completion: {
                // Gets the exchange rate from the internet:
                self.exchangeRates = self.xmlParser.getExchangeRates()
                // Saves the updated exchange rate to the device's local storage:
                //            CurrencyConverterLocalData.saveMostRecentExchangeRates(self.exchangeRates)
                // Runs the completion:
                completion()
            }, errorCompletion: { // No internet access/network error:
                // Loads the most recent exchange rate from the device's local storage:
                //            self.exchangeRates = CurrencyConverterLocalData.loadMostRecentExchangeRates()
                // Runs the completion:
                completion()
            })
        }
    }

    /**
     Converts a Double value based on it's currency (valueCurrency) and the output currency (outputCurrency).
     USD to EUR conversion example: convert(42, valueCurrency: .USD, outputCurrency: .EUR)
     */
    public func convert(_ value: Double, valueCurrency: Currency, outputCurrency: Currency) -> Double? {
        guard let valueRate = exchangeRates[valueCurrency] else { return nil }
        guard let outputRate = exchangeRates[outputCurrency] else { return nil }
        let multiplier = outputRate/valueRate
        return value * multiplier
    }
}

// Private Classes:
private class CurrencyXMLParser: NSObject, XMLParserDelegate {

    // Private Properties:
    private let xmlURL = "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml"
    private var exchangeRates: [Currency: Double] = [
        .EUR: 1.0, // Base currency
    ]

    // Public Methods:
    public func getExchangeRates() -> [Currency: Double] {
        return exchangeRates
    }

    public func parse(completion : @escaping () -> Void, errorCompletion : @escaping () -> Void) {
        guard let url = URL(string: xmlURL) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Failed to parse the XML!")
                print(error ?? "Unknown error")
                errorCompletion()
                return
            }
            let parser = XMLParser(data: data)
            parser.delegate = self
            if parser.parse() {
                completion()
            } else {
                errorCompletion()
            }
        }
        task.resume()
    }

    // Private Methods:
    private func makeExchangeRate(currency: String, rate: String) -> (currency: Currency, rate: Double)? {
        guard let currency = Currency(rawValue: currency) else { return nil }
        guard let rate = Double(rate) else { return nil }
        return (currency, rate)
    }

    // XML Parse Methods (from XMLParserDelegate):
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        if elementName == "Cube"{
            guard let currency = attributeDict["currency"] else { return }
            guard let rate = attributeDict["rate"] else { return }
            guard let exchangeRate = makeExchangeRate(currency: currency, rate: rate) else { return }
            exchangeRates.updateValue(exchangeRate.rate, forKey: exchangeRate.currency)
        }
    }

}
