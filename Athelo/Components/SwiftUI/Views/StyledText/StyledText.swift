//
//  StyledTextView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 12/06/2022.
//

import SwiftUI

struct StyledText: View {
    let text: String
    let textStyle: UIFont.AppStyle
    let colorStyle: UIColor.AppStyle
    let alignment: Alignment
    let extending: Bool
    let underlined: Bool
    
    private var font: UIFont {
        .withStyle(textStyle)
    }
    
    init(_ text: String, textStyle: UIFont.AppStyle, colorStyle: UIColor.AppStyle, extending: Bool = true, alignment: Alignment = .center, underlined: Bool = false) {
        self.text = text
        self.textStyle = textStyle
        self.colorStyle = colorStyle
        self.alignment = alignment
        self.extending = extending
        self.underlined = underlined
    }
    
    var body: some View {
        Text(text)
            .underline(underlined)
            .lineSpacing((font.capHeight - font.descender) * 0.24)
            .font(Font(font as CTFont))
            .foregroundColor(Color(UIColor.withStyle(colorStyle).cgColor))
            .multilineTextAlignment(textAlignment(from: alignment))
            .frame(maxWidth: extending ? .infinity : nil, alignment: alignment)
    }
    
    private func textAlignment(from alignment: Alignment) -> TextAlignment {
        switch alignment {
        case .trailing:
            return .trailing
        case .leading:
            return .leading
        case .center:
            return .center
        default:
            return .center
        }
    }
}

struct StyledTextView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            StyledText("home.header.wellbeing".localized(),
                textStyle: .subheading,
                colorStyle: .lightOlivaceous,
                alignment: .leading,
                underlined: true
            )
            .padding()
        }
    }
}
