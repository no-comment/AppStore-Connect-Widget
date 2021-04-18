//
//  IntentHandler.swift
//  WidgetIntentExtension
//
//  Created by Miká Kruschel on 04.04.21.
//

import Intents
import Foundation

class IntentHandler: INExtension, WidgetConfigurationIntentHandling {
    func provideApiKeyOptionsCollection(for intent: WidgetConfigurationIntent, with completion: @escaping (INObjectCollection<ApiKeyParam>?, Error?) -> Void) {
        let keys = APIKey.getApiKeys()
        let collection = INObjectCollection(items: keys.map({ ApiKeyParam(key: $0) }))
        completion(collection, nil)
    }

    func defaultApiKey(for intent: WidgetConfigurationIntent) -> ApiKeyParam? {
        guard let key = APIKey.getApiKeys().first else { return nil }
        return ApiKeyParam(key: key)
    }

    func provideCurrencyOptionsCollection(for intent: WidgetConfigurationIntent, with completion: @escaping (INObjectCollection<CurrencyParam>?, Error?) -> Void) {
        var identifiers = Currency.allCases.map({ $0.rawValue })
        let first = ["USD", "EUR", "GBP"]
        identifiers = identifiers.filter({ !first.contains($0) }).sorted()
        identifiers.insert(contentsOf: first, at: 0)

        var items = identifiers.map({ CurrencyParam(identifier: $0, display: $0) })
        items.insert(.system, at: 0)
        let collection = INObjectCollection(items: items)
        completion(collection, nil)
    }

    func defaultCurrency(for intent: WidgetConfigurationIntent) -> CurrencyParam? {
        return .system
    }

    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.

        return self
    }

}
