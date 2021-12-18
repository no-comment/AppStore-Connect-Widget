//
//  RefreshableScrollView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct RefreshableScrollView<Content: View>: View {
    init(onRefresh: @escaping () async -> Void, @ViewBuilder content: () -> Content) {
        self.onRefresh = onRefresh
        self.content = content()
    }

    let content: Content
    let onRefresh: () async -> Void

    var body: some View {
        List {
            ScrollView {
                content
            }
            .listRowSeparatorTint(Color.clear)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
        .listStyle(.plain)
        .refreshable {
            await onRefresh()
        }
    }
}
