//
//  AppSelectionView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct AppListView: View {
    @EnvironmentObject var dataProvider: ACDataProvider

    private var apps: [ACApp] {
        dataProvider.data?.apps ?? []
    }

    var body: some View {
        RefreshableScrollView(onRefresh: {
            await dataProvider.refreshData(useMemoization: false)
        }) {
            if dataProvider.data == nil {
                HStack(spacing: 10) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())

                    Text("LOADING_DATA")
                        .foregroundColor(.gray)
                        .italic()
                }
                .padding(.top, 25)
                .frame(maxWidth: .infinity)
            } else if apps.isEmpty {
                Text("NO_APPS")
            } else {
                ForEach(apps) { app in
                    NavigationLink(destination: {
                        Text("TODO")
                    }, label: {
                        AppRow(app: app)
                            .padding(.vertical, 10)
                    })
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("APPS")
        .secondaryBackground()
    }
}

struct AppRow: View {
    @EnvironmentObject var dataProvider: ACDataProvider
    let app: ACApp

    @State private var downloads = "-"
    @State private var proceeds = "-"
    @State private var updates = "-"

    @State private var noData = true

    var body: some View {
        Card(spacing: 7, innerPadding: 10) {
            HStack {
                HStack {
                    Group {
                        if let data = app.artwork60ImgData, let uiImg = UIImage(data: data) {
                            Image(uiImage: uiImg)
                                .resizable()
                                .scaledToFit()
                                .unredacted()
                        } else {
                            // Rectangle().foregroundColor(.secondary)
                        }
                    }
                    .frame(width: 25, height: 25)
                    .clipShape(RoundedRectangle(cornerRadius: 25 / 6.4, style: .continuous))
                    .shadow(color: .black.opacity(15 / 100), radius: 6, x: 0, y: 2)

                    Text(app.name)
                        .font(.subheadline.weight(.semibold))
                        .unredacted()
                }

                Spacer()

                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(dataProvider.data?.latestReportingDate() ?? "")
                    Image(systemName: "chevron.right").unredacted()
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            HStack(alignment: .bottom) {
                Spacer(minLength: 0)
                valueLabel(downloads, type: .downloads)
                divider
                valueLabel(proceeds, type: .proceeds)
                divider
                valueLabel(updates, type: .updates)
                Spacer(minLength: 0)
            }
        }
        .noDataOverlay(noData, short: true)
        .onAppear(perform: refresh)
        .onReceive(dataProvider.$data) { _ in refresh() }
        .frame(maxHeight: 120)
    }

    private func refresh() {
        guard let downloadsData = dataProvider.data?.getLastRawData(for: .downloads, filteredApps: [app]),
              let proceedsData = dataProvider.data?.getLastRawData(for: .proceeds, filteredApps: [app]),
              let updatesData = dataProvider.data?.getLastRawData(for: .updates, filteredApps: [app])
        else {
            downloads = "-"
            proceeds = "-"
            updates = "-"
            noData = true
            return
        }
        downloads = downloadsData.0.toString(abbreviation: .intelligent, maxFractionDigits: 0)
        proceeds = proceedsData.0.toString(abbreviation: .intelligent, maxFractionDigits: 2)
        updates = updatesData.0.toString(abbreviation: .intelligent, maxFractionDigits: 0)
        noData = false
    }

    private func valueLabel(_ value: String, type: InfoType) -> some View {
        VStack(spacing: 5) {
            Text(type.title)
                .foregroundColor(type.color)
                .font(.subheadline)
                .fontWeight(.medium)
                .unredacted()
            UnitText(value, infoType: type, currencySymbol: dataProvider.displayCurrencySymbol)
                .offset(x: 5)
        }
    }

    private var divider: some View {
        Group {
            Spacer(minLength: 0)
            Divider()
            Spacer(minLength: 0)
        }
    }
}

struct AppSelectionView_Previews: PreviewProvider {
    private static let test = [
        ACApp(appstoreId: "1", name: "My first App", sku: "", version: "", currentVersionReleaseDate: "", artworkUrl60: "", artworkUrl100: "", artwork60ImgData: nil),
        ACApp.mockApp,
        ACApp(appstoreId: "3", name: "My pretty App", sku: "", version: "", currentVersionReleaseDate: "", artworkUrl60: "", artworkUrl100: "", artwork60ImgData: nil),
        ACApp(appstoreId: "4", name: "My ugly App", sku: "", version: "", currentVersionReleaseDate: "", artworkUrl60: "", artworkUrl100: "", artwork60ImgData: nil),
        ACApp(appstoreId: "5", name: "My awesome App", sku: "", version: "", currentVersionReleaseDate: "", artworkUrl60: "", artworkUrl100: "", artwork60ImgData: nil),
    ]

    static var previews: some View {
        NavigationView {
            //                ForEach(AppSelectionView_Previews.test) { AppRow(app: $0).padding(.horizontal) }
            //                    .secondaryBackground()
            //                    .environmentObject(ACDataProvider.example)

            AppListView()
                .secondaryBackground()
                .environmentObject(ACDataProvider.example)
        }
    }
}
