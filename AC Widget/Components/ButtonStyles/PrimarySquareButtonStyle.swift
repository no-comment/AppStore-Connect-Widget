//
//  PrimaryButtonStyle.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

public struct PrimarySquareButtonStyle: ButtonStyle {
    private var color: Color = .accentColor
    private var foregroundColor: Color = .white
    private var scheme: ColorScheme = .light

    public init(color: Color = .accentColor,
                foregroundColor: Color = .white,
                scheme: ColorScheme = .light
    ) {
        self.color = color
        self.foregroundColor = foregroundColor
        self.scheme = scheme
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(scheme == .dark ? color : foregroundColor)
            .frame(idealWidth: 10, maxWidth: 10, idealHeight: 10, maxHeight: 10, alignment: .center)
            .padding(18)
            .background(color.opacity(scheme == .dark ? 0.15 : 1))
            .cornerRadius(10)
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

struct PrimarySquareButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Button(action: {}, label: { Image(systemName: "chevron.left") })
                .buttonStyle(PrimarySquareButtonStyle(scheme: .light))
                .padding()

            Button(action: {}, label: { Image(systemName: "pencil") })
                .buttonStyle(PrimarySquareButtonStyle(scheme: .dark))
                .padding()
                .preferredColorScheme(.dark)
        }
    }
}
