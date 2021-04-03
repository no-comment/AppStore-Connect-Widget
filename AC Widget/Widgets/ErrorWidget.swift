//
//  ErrorWidget.swift
//  AC Widget
//
//  Created by Cameron Shemilt on 01.04.21.
//

import SwiftUI
import WidgetKit

struct ErrorWidget: View {
    let error: APIError
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.red)
            
            Text("ERROR")
                .font(.system(size: 22, weight: .medium, design: .rounded))
            
            Text(error.userDescription)
                .multilineTextAlignment(.center)
                .font(.system(size: 14))
        }
        .minimumScaleFactor(0.5)
        .padding()
    }
}

struct ErrorWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ErrorWidget(error: .wrongPermissions)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            ErrorWidget(error: .exceededLimit)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            ErrorWidget(error: .exceededLimit)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
