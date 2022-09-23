//
//  SleepStatsSingleStatView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/07/2022.
//

import SwiftUI

struct SleepStatsSingleStatView: View {
    let header: String
    let text: String
    
    var body: some View {
        VStack(spacing: 8.0) {
            StyledText(header,
                       textStyle: .boldHeadline24,
                       colorStyle: .lightOlivaceous,
                       alignment: .leading)
            
            StyledText(text,
                       textStyle: .body,
                       colorStyle: .gray,
                       alignment: .leading)
        }
        .padding(24.0)
        .background(
            ZStack {
                Rectangle()
                    .fill(Color(UIColor.withStyle(.white).cgColor))
                
                Image("wavesBackground")
                    .opacity(0.2)
                    .offset(x: 0.0, y: 20.0)
            }
        )
        .cornerRadius(30.0)
        .styledShadow()
    }
}

struct SleepStatsSingleStatView_Previews: PreviewProvider {
    static var previews: some View {
        SleepStatsSingleStatView(header: "4h 33m", text: "Deep Sleep")
            .padding()
    }
}
