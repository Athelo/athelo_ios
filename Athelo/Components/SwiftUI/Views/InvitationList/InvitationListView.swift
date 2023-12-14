//
//  InvitationListView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 30/03/2023.
//

import SwiftUI

final class InvitationListModel: ObservableObject {
    @Published private(set) var invitations: [HealthInvitationData] = []
    
    func updateInvitations(_ invitations: [HealthInvitationData], animated: Bool = false) {
        withExplicitAnimation(animated) {
            self.invitations = invitations
        }
    }
}

struct InvitationListView: View {
    @ObservedObject var model: InvitationListModel
    let additionalTopContentOffset: CGFloat
    
    let onDeleteTapped: ((HealthInvitationData) -> Void)?
    
    init(model: InvitationListModel, additionalTopContentOffset: CGFloat? = nil, onDeleteTapped: ((HealthInvitationData) -> Void)? = nil) {
        self.model = model
        self.additionalTopContentOffset = max(additionalTopContentOffset ?? 0.0, 0.0)
        self.onDeleteTapped = onDeleteTapped
    }
    
    var body: some View {
        ZStack {
            FadingScrollView {
                VStack(spacing: 24.0) {
                    ForEach(model.invitations) { invitation in
                        InvitationItemView(
                            invitation: invitation,
                            onDeleteTapped: onDeleteTapped
                        )
                    }
                }
                .padding(.vertical, 24.0)
                .padding(.top, additionalTopContentOffset)
                .padding(.horizontal, 16.0)
            }
            
            if model.invitations.isEmpty {
                VStack(spacing: 24.0) {
                    StyledText(
                        "nocontent.body.short".localized(),
                        textStyle: .headline20,
                        colorStyle: .black
                    )
                    
                    StyledText(
                        "nocontent.invitations".localized(),
                        textStyle: .intro,
                        colorStyle: .purple623E61
                    )
                    
                    Spacer()
                }
                .padding(.top, 48.0 + additionalTopContentOffset)
                .padding(.horizontal, 16.0)
            }
        }
    }
}

struct InvitationListView_Previews: PreviewProvider {
    static let model: InvitationListModel = {
        let model = InvitationListModel()
        
        model.updateInvitations([
            .sample,
            .sample,
            .sample
        ])
        
        return model
    }()
    
    static var previews: some View {
        InvitationListView(model: model) { _ in
            /* ... */
        }
        .background(
            Rectangle()
                .fill(.blue)
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
