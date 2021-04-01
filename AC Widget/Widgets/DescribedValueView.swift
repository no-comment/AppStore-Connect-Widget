//
//  DescribedValueView.swift
//  AC Widget
//
//  Created by Cameron Shemilt on 01.04.21.
//

import SwiftUI
import WidgetKit

struct DescribedValueView: View {
    let description: Text
    let value: String
    
    init(_ description: String, value: String) {
        self.description = Text(description)
        self.value = value
    }
    
    init(_ description: LocalizedStringKey, value: String) {
        self.description = Text(description)
        self.value = value
    }
    
    var body: some View {
        HStack(spacing: 0) {
            description
                .font(.system(size: 17, weight: .regular, design: .default))
                .foregroundColor(.gray)
                .minimumScaleFactor(0.6)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .minimumScaleFactor(0.75)
        }
        .lineLimit(1)
    }
}

struct DescribedValueView_Previews: PreviewProvider {
    static var previews: some View {
        DescribedValueView("30 Days:", value: "2.8k$")
            .padding()
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
