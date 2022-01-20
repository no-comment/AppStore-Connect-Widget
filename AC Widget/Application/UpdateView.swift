//
//  UpdateView.swift
//  AC Widget by NO-COMMENT
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
            UpdateDetailView(systemName: "arrow.triangle.branch", title: "UPDATE_TITLE_1", subTitle: "UPDATE_SUBTITLE_1")
            UpdateDetailView(systemName: "plus.bubble.fill", title: "UPDATE_TITLE_2", subTitle: "UPDATE_SUBTITLE_2")
            UpdateDetailView(systemName: "internaldrive", title: "UPDATE_TITLE_3", subTitle: "UPDATE_SUBTITLE_3")
            UpdateDetailView(systemName: "arrow.down", title: "UPDATE_TITLE_4", subTitle: "UPDATE_SUBTITLE_4")
            UpdateDetailView(systemName: "wrench.and.screwdriver", title: "UPDATE_TITLE_5", subTitle: "UPDATE_SUBTITLE_5")
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
