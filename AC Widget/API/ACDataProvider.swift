//
//  ACDataProvider.swift
//  AC Widget by NO-COMMENT
//

import Combine
import SwiftUI
import WidgetKit

class ACDataProvider: ObservableObject {
    private var anyCancellable: AnyCancellable?

    @Published public var data: ACData?
    @Published public var error: APIError?
    @Published public var apiKeysProvider: APIKeyProvider

    @AppStorage(UserDefaultsKey.homeSelectedKey, store: UserDefaults.shared) public var keyID: String = "" {
        didSet { refresh() }
    }

    @AppStorage(UserDefaultsKey.homeCurrency, store: UserDefaults.shared) public var currency: String = Currency.USD.rawValue {
        didSet { refresh() }
    }

    public var displayCurrencySymbol: String {
        return data?.displayCurrency.symbol ?? "$"
    }

    public var selectedKey: APIKey? {
        return apiKeysProvider.getApiKey(apiKeyId: keyID) ?? apiKeysProvider.apiKeys.first
    }

    init() {
        data = nil
        error = nil
        apiKeysProvider = APIKeyProvider()

        anyCancellable = apiKeysProvider.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }

        refresh()
    }

    private func refresh() {
        data = nil
        error = nil

        // load cached data
        guard let apiKey = selectedKey else {
            data = nil
            error = .unknown
            return
        }
        data = ACDataCache.getData(apiKey: apiKey)

        // load data from api
        Task {
            await CurrencyConverter.shared.updateExchangeRates()
            await refreshData()
        }
    }

    @MainActor
    public func refreshData(useMemoization: Bool = true) async {
        guard let apiKey = selectedKey else {
            data = nil
            error = .unknown
            return
        }
        let api = await AppStoreConnectApi(apiKey: apiKey)
        do {
            data = try await api.getData(currency: Currency(rawValue: currency), useMemoization: useMemoization)
            WidgetCenter.shared.reloadAllTimelines()
            error = nil
        } catch let err as APIError {
            self.error = err
        } catch {
            self.error = .unknown
        }
    }
}

private extension UserDefaultsKey {
    static let homeSelectedKey = "homeSelectedKey"
    static let homeCurrency = "homeCurrency"
}

extension ACDataProvider {
    static let example: ACDataProvider = {
        let provider = ACDataProvider()
        provider.data = .example
        return provider
    }()

    static let exampleNoData: ACDataProvider = {
        let provider = ACDataProvider()
        provider.data = nil
        return provider
    }()

    static let exampleLargeSums: ACDataProvider = {
        let provider = ACDataProvider()
        provider.data = .exampleLargeSums
        return provider
    }()
}
