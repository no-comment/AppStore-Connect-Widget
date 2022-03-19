//
//  DynamicWidthChartRow.swift
//  AC Widget by NO-COMMENT
//
import SwiftUI

struct DynamicWidthChartRow<ShortContent: View, LongContent: View>: View {
    let color: Color
    let contrastColor: Color
    let width: CGFloat

    let shortContent: ShortContent
    let longContent: LongContent

    init(color: Color, contrastColor: Color, width: CGFloat, @ViewBuilder shortContent: () -> ShortContent, @ViewBuilder longContent: () -> LongContent) {
        self.shortContent = shortContent()
        self.longContent = longContent()
        self.color = color
        self.contrastColor = contrastColor
        self.width = width
    }

    @State private var small: Bool = false

    var body: some View {
        if small {
            HStack {
                RoundedRectangle(cornerRadius: 6)
                    .foregroundColor(color)
                    .frame(width: width)
                shortContent
                    .fixedSize(horizontal: true, vertical: false)
            }
        } else {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .foregroundColor(color)
                    .frame(width: width)

                longContent
                    .fixedSize(horizontal: true, vertical: false)
                    .readSize { size in
                        guard size.width != 0 && width != 0 else { return }
                        if size.width + 10 > width {
                            small = true
                        }
                    }
                    .foregroundColor(contrastColor)
                    .font(.system(size: 15, weight: .semibold))
                    .padding(.horizontal, 8)
                    .frame(width: width, alignment: .leading)
            }
            .frame(width: width)
        }
    }
}

fileprivate extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
