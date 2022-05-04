//
//  HomeView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import AppStoreConnect_Swift_SDK
import StoreKit

struct HomeView: View {
    @EnvironmentObject var dataProvider: ACDataProvider

    @AppStorage(UserDefaultsKey.appStoreNotice, store: UserDefaults.shared) var appStoreNotice: Bool = true
    @AppStorage(UserDefaultsKey.rateCount, store: UserDefaults.shared) var rateCount: Int = 0
    @AppStorage(UserDefaultsKey.lastSeenVersion, store: UserDefaults.shared) private var lastSeenVersion: String = ""

    @State var showSettings = false
    @State private var showsUpdateScreen = false

    var body: some View {
        RefreshableScrollView(onRefresh: {
            await dataProvider.refreshData(useMemoization: false)
        }) {
            if dataProvider.data != nil {
                lastChangeSubtitle
                if appStoreNotice && AppStoreNotice.isTestFlight() {
                    AppStoreNotice()
                }
                CardSection {
                    if let error = dataProvider.error {
                        ErrorCard(error: error)
                    }
                    SummaryCard(type: .downloads, header: true)
                    SummaryCard(type: .proceeds, header: true)
                    SummaryCard(type: .updates, header: true)
                    SummaryCard(type: .iap, header: true)
                }
                trendsSection
                additionalInformation
            } else {
                loadingIndicator
            }
        }
        .background(
            NavigationLink(destination: SettingsView(), isActive: $showSettings) {
                EmptyView()
            }
        )
        .navigationTitle("Home")
        .sheet(isPresented: $showsUpdateScreen, content: {
            UpdateView()
        })
        .onAppear(perform: onAppear)
        .task { await dataProvider.refreshData(useMemoization: true) }
        .secondaryBackground()
    }

    private var trendsSection: some View {
        CardSection("Trends") {
            // TODO: Add basic logic for displaying trends 'intelligent'
            WeeklyAverageCard(type: .downloads, header: true)
        }
    }

    private var loadingIndicator: some View {
        HStack(spacing: 10) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())

            Text("Loading Data")
                .foregroundColor(.gray)
                .italic()
        }
        .padding(.top, 25)
        .frame(maxWidth: .infinity)
    }

    private var lastChangeSubtitle: some View {
        HStack {
            Text("Last Change: \(dataProvider.data?.latestReportingDate() ?? "-")")
                .font(.subheadline)
            Spacer()
        }
        .padding(.horizontal)
    }

    private var additionalInformation: some View {
        VStack(spacing: 20) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 8) {
                Text("Last Change: \(dataProvider.data?.latestReportingDate() ?? "-")")
                    .font(.system(size: 12))
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Currency: \(dataProvider.data?.displayCurrency.rawValue ?? "-")")
                    .font(.system(size: 12))
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("API Key: \(dataProvider.selectedKey?.name ?? "-")")
                    .font(.system(size: 12))
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if dataProvider.data != nil {
                AsyncButton(action: {
                    await dataProvider.refreshData(useMemoization: false)
                }) {
                    Text("Refresh Data")
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 20)
                .background(Color.cardColor)
                .clipShape(Capsule())
                .foregroundColor(.primary)
            }
        }
        .foregroundColor(.gray)
        .padding()
    }

    private func onAppear() {
        askToRate()

        let appVersion: String = UIApplication.appVersion ?? ""
        let buildVersion: String = UIApplication.buildVersion ?? ""
        let vString = "\(appVersion) (\(buildVersion))"
        if vString != lastSeenVersion {
            lastSeenVersion = vString
            showsUpdateScreen = true
            appStoreNotice = true
        }
    }

    private func askToRate() {
        let daysSinceInstall = Calendar.current.numberOfDaysBetween(Date.appInstallDate, and: .now)
        if daysSinceInstall > (rateCount + 1) * 20 {
            // equivalent to rateCount += 1 in most cases, except if app is installed a long time ago but no review done
            rateCount = Int(ceil(Double(daysSinceInstall - 20) / 20))
            let later = DispatchTime.now() + 5
            DispatchQueue.main.asyncAfter(deadline: later) {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                HomeView()
            }

            NavigationView {
                HomeView()
            }
            .preferredColorScheme(.dark)
        }
        .environmentObject(ACDataProvider.example)
    }
}
