//
//  UpdateView.swift
//  AC Widget
//
//  Created by Miká Kruschel on 26.09.21.
//

import SwiftUI

struct UpdateView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                ScrollView(.vertical) {
                    infoSection

                    Spacer(minLength: 30)
                }

                if let link = URL(string: "https://github.com/no-comment/AppStore-Connect-Widget") {
                    Link("IDEA_BUG_LINK", destination: link)
                }

                Button(action: {
                    dismiss()
                }) {
                    Text("START")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .frame(minWidth: 0, maxWidth: 500, alignment: .center)
                        .background(Color.blue)
                        .cornerRadius(15)
                }
                .padding()
            }
            .navigationTitle("WHATS_NEW")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    var infoSection: some View {
        VStack(alignment: .leading) {
            UpdateDetailView(systemName: "icloud", title: "UPDATE_TITLE_1", subTitle: "UPDATE_SUBTITLE_1")

            UpdateDetailView(systemName: "apps.ipad.landscape", title: "UPDATE_TITLE_2", subTitle: "UPDATE_SUBTITLE_2")

            UpdateDetailView(systemName: "line.3.horizontal.decrease.circle", title: "UPDATE_TITLE_3", subTitle: "UPDATE_SUBTITLE_3")

            UpdateDetailView(systemName: "chart.pie", title: "UPDATE_TITLE_4", subTitle: "UPDATE_SUBTITLE_4")
        }
        .frame(maxWidth: 430)
        .padding(.horizontal)
    }
}

struct UpdateView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateView()

        UpdateView()
            .environment(\.locale, .init(identifier: "de"))
    }
}
