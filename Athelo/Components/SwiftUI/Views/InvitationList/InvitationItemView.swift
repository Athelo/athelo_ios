//
//  InvitationItemView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 30/03/2023.
//

import SwiftUI

struct InvitationItemView: View {
    let invitation: HealthInvitationData
    
    let onDeleteTapped: ((HealthInvitationData) -> Void)?
    
    init(invitation: HealthInvitationData, onDeleteTapped: ((HealthInvitationData) -> Void)? = nil) {
        self.invitation = invitation
        self.onDeleteTapped = onDeleteTapped
    }
    
    var body: some View {
        HStack(spacing: 16.0) {
            VStack(spacing: 8.0) {
                StyledText(
                    invitation.receiverNickName,
                    textStyle: .subheading,
                    colorStyle: .gray,
                    extending: true,
                    alignment: .leading
                )
                
                StyledText(
                    invitation.email,
                    textStyle: .body,
                    colorStyle: .gray,
                    extending: true,
                    alignment: .leading
                )
            }
            
            if onDeleteTapped != nil {
                Button {
                    onDeleteTapped?(invitation)
                } label: {
                    Image("close")
                        .renderingMode(.template)
                        .foregroundColor(.red)
                        .frame(width: 38.0, height: 38.0)
                        .background(
                            Rectangle()
                                .fill(Color(UIColor.withStyle(.redE31A1A).cgColor))
                                .opacity(0.17)
                                .roundedCorners(radius: 8.0)
                        )
                }
            }
        }
        .padding(.vertical, 24.0)
        .padding(.horizontal, 16.0)
        .background(
            Rectangle()
                .fill(.white)
        )
        .roundedCorners(radius: 30.0)
        .styledShadow()
    }
}

struct InvitationItemView_Previews: PreviewProvider {
    static var previews: some View {
        InvitationItemView(invitation: .sample)
            .background(
                Rectangle()
                    .fill(.black)
            )
    }
}

private extension HealthInvitationData {
    static var sample: HealthInvitationData {
        HealthInvitationData(
            id: Int.random(in: (0)...(.max)),
            name: UUID().uuidString,
            email: UUID().uuidString
        )
    }
    
    init(id: Int, name: String, email: String) {
        self.id = id
        self.receiverNickName = name
        self.email = email
        
        self.code = "code"
        self.expiresAt = Date()
        self.status = "status"
        self.relationLabel = "relation_label"
    }
}
