//
//  CaregiverListScreen.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 30/03/2023.
//

import Combine
import SwiftUI

enum CaregiverListTab: Hashable, CaseIterable {
    case caregivers
    case invitations
    
    var name: String {
        switch self {
        case .caregivers:
            return "All"
        case .invitations:
            return "Pending"
        }
    }
}

final class CaregiverListModel: ObservableObject {
    // MARK: - Properties
    @Published var activeTab: CaregiverListTab = .caregivers
    @Published var noCaregiversVisible: Bool = false
    
    let caregiversModel: ContactListModel
    let invitationsModel: InvitationListModel
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    init(caregiversModel: ContactListModel, invitationsModel: InvitationListModel) {
        self.caregiversModel = caregiversModel
        self.invitationsModel = invitationsModel
        
        sink()
    }
    
    // MARK: - Public API
    func updateActiveTab(_ tab: CaregiverListTab, animated: Bool = true) {
        guard tab != activeTab else {
            return
        }
        
        withExplicitAnimation(animated, animation: .spring().speed(0.75)) {
            self.activeTab = tab
        }
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoCaregiversModel()
    }
    
    private func sinkIntoCaregiversModel() {
        caregiversModel.$contacts
            .dropFirst()
            .map({ $0.isEmpty })
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                withAnimation(.default.speed(1.5)) {
                    self?.noCaregiversVisible = value
                }
            }.store(in: &cancellables)
    }
}

struct CaregiverListScreen: View {
    @ObservedObject var model: CaregiverListModel
    let additionalTopContentOffset: CGFloat?
    
    let caregiverActions: [ContactItemAction]?
    let onDeleteInvitationCallback: ((HealthInvitationData) -> Void)?
    
    private var topContentOffset: CGFloat {
        max(0.0, additionalTopContentOffset ?? 0.0)
    }
    
    init(model: CaregiverListModel, additionalTopContentOffset: CGFloat? = nil,  caregiverActions: [ContactItemAction]? = nil, onDeleteInvitation: ((HealthInvitationData) -> Void)? = nil) {
        self.model = model
        self.additionalTopContentOffset = additionalTopContentOffset
        
        self.caregiverActions = caregiverActions
        self.onDeleteInvitationCallback = onDeleteInvitation
    }
    
    var body: some View {
        ZStack {
            if model.activeTab == .caregivers {
                ZStack {
                    VStack(spacing: 24.0) {
                        StyledText(
                            "nocontent.body.short".localized(),
                            textStyle: .headline20,
                            colorStyle: .black
                        )
                        
                        StyledText(
                            "nocontent.caregivers".localized(),
                            textStyle: .intro,
                            colorStyle: .purple623E61
                        )
                        
                        Spacer()
                    }
                    .padding(.top, 48.0 + topContentOffset)
                    .padding(.horizontal, 16.0)
                    .opacity(model.noCaregiversVisible ? 1.0 : 0.0)
                    
                    ContactListView(
                        model: model.caregiversModel,
                        actions: caregiverActions,
                        additionalTopContentOffset: additionalTopContentOffset
                    )
                }
                .transition(
                    .move(edge: .leading)
                )
            }
            
            if model.activeTab == .invitations {
                InvitationListView(
                    model: model.invitationsModel,
                    additionalTopContentOffset: additionalTopContentOffset,
                    onDeleteTapped: onDeleteInvitationCallback
                )
                .transition(
                    .move(edge: .trailing)
                )
            }
        }
    }
}

struct CaregiverListScreen_Previews: PreviewProvider {
    static let model: CaregiverListModel = {
        let contacts = IdentityCommonProfileData.samples
        let invitations = HealthInvitationData.samples
        
        let invitationsModel = InvitationListModel()
        invitationsModel.updateInvitations(invitations)
        
        return CaregiverListModel(
            caregiversModel: ContactListModel(contacts: contacts),
            invitationsModel: invitationsModel
        )
    }()
    
    static var previews: some View {
        VStack {
//            Button("Change tab") {
//                withAnimation(.spring()) {
//                    if model.activeTab == .invitations {
//                        model.activeTab = .caregivers
//                    } else {
//                        model.activeTab = .invitations
//                    }
//                }
//            }
//            .background(
//                Rectangle()
//                    .fill(.clear)
//            )
//
            CaregiverListScreen(model: model, additionalTopContentOffset: 20.0)
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
    
    static var samples: [HealthInvitationData] {
        (1...20).map({ _ in .sample })
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

private extension IdentityCommonProfileData {
    static func sample(id: Int) -> IdentityCommonProfileData {
        IdentityCommonProfileData(id: id, displayName: "User \(id)", imageURL: URL(string: "https://images.unsplash.com/photo-1512451590339-a3268f0402d9?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=320&q=80")!)
    }
    
    static var samples: [IdentityCommonProfileData] {
        (1...20).map({ .sample(id: $0) })
    }
    
    init(id: Int, displayName: String, imageURL: URL) {
        self.id = id
        self.photo = ImageData(
            id: 1,
            image: imageURL,
            image50px: imageURL,
            image100px: imageURL,
            image125px: imageURL,
            image250px: imageURL,
            image500px: imageURL,
            name: nil
        )
        
        self.profileFriendVisibilityOnly = nil
        self.displayName = displayName
    }
}
