////
////  BorderedText.swift
////  DomainExpansion
////
////  Created by Davide Castaldi on 21/05/25.
////
//
//import SwiftUI
//
///// A view that renders each character of the input text with an outline (stroke) around it.
//struct BorderedText: View {
//    /// The text to display with outlines
//    var text: String
//    /// The font to use for the text
//    var font: Font = .system(size: 48, weight: .bold)
//    /// The fill color of the text
//    var fillColor: UIColor = .black
//    /// The color of the outline (stroke)
//    var strokeColor: UIColor = .black
//    /// The width of the outline stroke
//    var lineWidth: CGFloat = 2
//
//    var body: some View {
//        HStack(spacing: 0) {
//            ForEach(text.utf8CString, id: \.self) { char in
//                let charString = String(char)
//                // Build an attributed string with stroke attributes
//                var attr = AttributedString(charString)
//                attr.strokeColor = strokeColor
//                // Negative strokeWidth draws both fill and stroke
//                attr.strokeWidth = -lineWidth
//
//                Text(attr)
//                    .font(font)
//                    .foregroundColor(fillColor)
//            }
//        }
//    }
//}
//
//// Preview for visionOS or iOS
//#Preview {
//    BorderedText(
//        text: "Hello",
//        font: .system(size: 72, weight: .heavy),
//        fillColor: .yellow,
//        strokeColor: .red,
//        lineWidth: 3
//    )
//}
