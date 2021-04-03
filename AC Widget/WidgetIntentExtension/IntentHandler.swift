//
//  IntentHandler.swift
//  WidgetIntentExtension
//
//  Created by Miká Kruschel on 03.04.21.
//

import Intents

class IntentHandler: INExtension, SelectCurrencyIntentHandling {
    func provideCurrencyOptionsCollection(for intent: SelectCurrencyIntent, with completion: @escaping (INObjectCollection<CurrencyParam>?, Error?) -> Void) {
        
        var identifiers = Currency.allCases.map({ $0.rawValue })
        let first = ["USD", "EUR", "GBP"]
        identifiers = identifiers.filter({ !first.contains($0) }).sorted()
        identifiers.insert(contentsOf: first, at: 0)
        identifiers.insert("System", at: 0)
        
        completion(
            INObjectCollection(items: identifiers.map({ CurrencyParam(identifier: $0, display: $0) }))
            , nil)
    }
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
}
