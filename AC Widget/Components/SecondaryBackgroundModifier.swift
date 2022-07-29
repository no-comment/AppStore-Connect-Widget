//
//  GreyBackgroundModifier.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

// struct SecondaryBackground: ViewModifier {
//    func body(content: Content) -> some View {
//        ZStack {
//            Color("BackgroundColor")
//                .ignoresSafeArea()
//            content
//        }
//    }
// }

extension View {
    func secondaryBackground() -> some View {
//        modifier(SecondaryBackground())
        self.background(Color("BackgroundColor").ignoresSafeArea())
    }
}
