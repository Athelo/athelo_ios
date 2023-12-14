//
//  SelectPatientView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 17/03/2023.
//

import SwiftUI

struct SelectPatientView: View {
    let patientData: ContactData
    
    @Binding private(set) var isSelected: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 16.0) {
            StyledImageView(imageData: .image(.init(named: "handHeartSolid")!), contentMode: .scaleAspectFit)
                .frame(width: 24.0, height: 24.0, alignment: .center)
            
            StyledText("Act as a caregiver for \(patientData.contactDisplayName ?? "this patient")",
                       textStyle: .button,
                       colorStyle: .gray,
                       extending: true,
                       alignment: .leading)
            
            RadioStateView(isSelected: $isSelected)
                .frame(width: 24.0, height: 24.0)
        }
        .padding(16.0)
        .frame(minHeight: 72.0, alignment: .center)
        .background(
            Rectangle().fill(.white)
        )
        .cornerRadius(20.0)
        .styledShadow()
    }
}

struct SelectPatientView_Previews: PreviewProvider {
    static var previews: some View {
        SelectPatientView(
            patientData: IdentityCommonProfileData.sample,
            isSelected: .constant(false)
        )
    }
}

private extension IdentityCommonProfileData {
    static var sample: IdentityCommonProfileData {
        .init(id: 1, displayName: "Suzie")
    }
    
    init(id: Int, displayName: String) {
        self.id = id
        
        self.displayName = displayName
        self.photo = nil
        self.profileFriendVisibilityOnly = nil
    }
}
