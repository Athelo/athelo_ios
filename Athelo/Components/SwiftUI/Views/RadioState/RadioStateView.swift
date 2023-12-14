//
//  RadioStateView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 17/03/2023.
//

import SwiftUI

struct RadioStateView: View {
    @Binding var isSelected: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(Color(UIColor.withStyle(.purple623E61)), lineWidth: 1.0)
            
            Circle()
                .fill(Color(UIColor.withStyle(.purple623E61)))
                .scaleEffect(isSelected ? 14.0 / 24.0 : 0.05)
                .opacity(isSelected ? 1.0 : 0.0)
        }
        .aspectRatio(1.0, contentMode: .fit)
    }
}

struct RadioStateView_Previews: PreviewProvider {
    static var previews: some View {
        RadioStateView(isSelected: .constant(true))
            .frame(width: 24.0, height: 24.0)
    }
}
