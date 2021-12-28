//
//  IntentHandler.swift
//  AC Widget by NO-COMMENT
//

import Intents
import Foundation

class IntentHandler: INExtension, WidgetConfigurationIntentHandling {
    func provideCurrencyOptionsCollection(for intent: WidgetConfigurationIntent) async throws -> INObjectCollection<CurrencyParam> {
        var items = Currency.sortedAllCases.map({ CurrencyParam(identifier: $0.rawValue, display: $0.rawValue) })
        items.insert(.system, at: 0)
        return .init(items: items)
    }

    func provideApiKeyOptionsCollection(for intent: WidgetConfigurationIntent) async throws -> INObjectCollection<ApiKeyParam> {
        let keys = APIKeyProvider().apiKeys
        return .init(items: keys.map({ ApiKeyParam(key: $0) }))
    }

    func provideFilteredAppsOptionsCollection(for intent: WidgetConfigurationIntent) async throws -> INObjectCollection<FilteredAppParam> {
        guard let apiKey = intent.apiKey?.toApiKey() else {
            throw INIntentError(.missingInformation)
        }

        do {
            let data = try await AppStoreConnectApi(apiKey: apiKey).getData()
            return .init(items: data.apps.map({ FilteredAppParam(identifier: $0.id, display: $0.name) }))
        } catch {
            throw INIntentError(.requestTimedOut)
        }
    }

    func defaultApiKey(for intent: WidgetConfigurationIntent) -> ApiKeyParam? {
        guard let key = APIKeyProvider().apiKeys.first else { return nil }
        return ApiKeyParam(key: key)
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
