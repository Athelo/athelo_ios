//
//  GraphSelectedItemInfoView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 11/08/2022.
//

import SwiftUI

struct GraphSelectedItemInfoView: View {
    @Binding var label: String?
    @Binding var secondaryLabel: String?
    
    var body: some View {
        HStack(alignment: .center, spacing: 4.0) {
            StyledText(label ?? "",
                       textStyle: .subtitle,
                       colorStyle: .lightOlivaceous,
                       extending: false)
            
            StyledText(secondaryLabel ?? "",
                       textStyle: .legend,
                       colorStyle: .lightGray,
                       extending: false)
            .offset(x: secondaryLabel?.isEmpty == false ? 0.0 : -4.0, y: 0.0)
        }
        .padding(8.0)
        .styledBackground(.withStyle(.white))
        .cornerRadius(12.0)
        .styledShadow()
    }
}

struct GraphSelectedItemInfoView_Previews: PreviewProvider {
    static var previews: some View {
        GraphSelectedItemInfoView(
            label: .constant("1298 steps"),
            secondaryLabel: .constant("- May 14")
        )
    }
}
