//
//  AppIconStack.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct AppIconStack: View {
    var apps: [ACApp]

    var body: some View {
        ZStack {
            ForEach(0..<min(apps.count, 3)) { index in
                AsyncImage(url: URL(string: apps[index].artworkUrl60)) { image in
                    image.resizable()
                } placeholder: {
                    Rectangle().foregroundColor(.secondaryCardColor)
                }
                .frame(width: 15, height: 15)
                .cornerRadius(3)
                .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.secondaryCardColor, lineWidth: 0.3)
                    )
                .padding(.leading, 12*CGFloat(index))
            }
            if apps.count > 3 {
                ZStack {
                    Image(systemName: "app.fill")
                        .foregroundColor(.secondaryCardColor)
                    Text("+\(apps.count-3)")
                        .font(.system(size: 8))
                        .minimumScaleFactor(0.5)
                }
                .frame(width: 15, height: 15)
                .padding(.leading, 36)
            }
        }
    }
}

struct AppIconStack_Previews: PreviewProvider {
    static var previews: some View {
        AppIconStack(apps: [ACData.example.apps[0], ACData.example.apps[0], ACData.example.apps[0], ACData.example.apps[0], ACData.example.apps[0]])
    }
}
