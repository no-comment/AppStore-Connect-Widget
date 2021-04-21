//
//  Card.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct Card<Content: View>: View {
    let content: Content
    var alignment: HorizontalAlignment
    var spacing: CGFloat?
    var padding: CGFloat
    var color: Color

    init(alignment: HorizontalAlignment = .center,
         spacing: CGFloat? = nil,
         innerPadding: CGFloat = 17,
         color: Color = Color.widgetSecondary,
         @ViewBuilder content: () -> Content) {
        self.content = content()
        self.alignment = alignment
        self.spacing = spacing
        self.padding = innerPadding
        self.color = color
    }

    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            content
        }
        .padding(padding)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(color)
        )
    }
}

struct Card_Previews: PreviewProvider {
    static var previews: some View {
        Card {
            Text("Content Within")
        }.padding()
    }
}
