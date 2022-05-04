//
//  DescribedValueView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import WidgetKit

struct DescribedValueView: View {
    let description: Text
    let value: String

    init(description: LocalizedStringKey, value: String) {
        self.description = Text(description)
        self.value = value
    }

    init(descriptionString: String, value: String) {
        self.description = Text(descriptionString)
        self.value = value
    }

    var body: some View {
        HStack(spacing: 0) {
            description
                .font(.body)
                .foregroundColor(.gray)
                .minimumScaleFactor(0.6)
                .unredacted()

            Spacer(minLength: 5)

            Text(value)
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .minimumScaleFactor(0.75)
        }
        .lineLimit(1)
    }
}

struct DescribedValueView_Previews: PreviewProvider {
    static var previews: some View {
        DescribedValueView(description: "30 Days:", value: "2.8k$")
            .padding()
        //            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .previewLayout(.fixed(width: 164, height: 164))

    }
}
