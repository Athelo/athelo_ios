//
//  SummarySingleStatView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 26/07/2022.
//

import SwiftUI

struct SummarySingleStatView: View {
    let icon: UIImage
    let header: String
    let bodyText: String
    let tintColor: UIColor
    
    var body: some View {
        HStack(alignment: .top, spacing: 8.0) {
            Image(uiImage: icon.withRenderingMode(.alwaysTemplate))
                .foregroundColor(Color(tintColor.cgColor))
            
            VStack(spacing: 4.0) {
                StyledText(header,
                           textStyle: .button,
                           colorStyle: .black,
                           alignment: .leading)
                
                StyledText(bodyText,
                           textStyle: .body,
                           colorStyle: .lightGray,
                           alignment: .leading)
            }
        }
    }
}

struct SummarySingleStatView_Previews: PreviewProvider {
    static var previews: some View {
        SummarySingleStatView(
            icon: .init(named: "bookSolid")!,
            header: "4h 33m",
            bodyText: "Deep Sleep",
            tintColor: .withStyle(.lightOlivaceous)
        )
    }
}
