//
//  PatientRoleScreen.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 20/03/2023.
//

import SwiftUI

struct PatientRoleScreen: View {
    private enum Constants {
        @MainActor static var headerRatio: Double {
//            #if targetEnvironment(simulator)
//            return 375.0 / 475.0
//            #else
            let denominator = min(475.0, AppRouter.current.window.bounds.size.height - 300.0)
            return 375.0 / denominator
//            #endif
        }
    }
    
    @ObservedObject private(set) var model: PatientRoleModel
    
    private(set) var onAddACaregiver: () -> Void
    private(set) var onContinue: () -> Void
    private(set) var onRemoveCaregiver: (ContactData) -> Void
    
    var body: some View {
        ZStack {
            if !model.hasCaregivers {
                VStack {
                    BottomClippedGradientView(
                        imageData: .init(
                            image: .init(named: "womanPhone")!,
                            shouldClip: true,
                            yOffset: 0.0,
                            topContentInset: model.headerTopContentInset
                        )
                    )
                    .aspectRatio(Constants.headerRatio, contentMode: .fit)
                    
                    Spacer()
                }
            }
            
            VStack(spacing: 24.0) {
                if model.hasCaregivers {                    
                    ScrollView {
                        LazyVStack(spacing: 24.0) {
                            ForEach(model.caregivers, id: \.contactID) { caregiver in
                                ContactItemView(
                                    personData: caregiver,
                                    actions: [
                                        .init(icon: .init(named: "trashBinSolid")!, action: onRemoveCaregiver)
                                    ],
                                    onTap: nil
                                )
                            }
                        }
                        .padding(.horizontal, 16.0)
                        .padding(.top, 24.0)
                    }
                    .clipped()
                } else {
                    Spacer()
                        .aspectRatio(Constants.headerRatio, contentMode: .fit)
                    
                    Group {
                        StyledText(
                            "nocontent.body.short".localized(),
                            textStyle: .headline20,
                            colorStyle: .black,
                            alignment: .center
                        )
                        
                        StyledText(
                            "role.patient.mgmt.prompt".localized(),
                            textStyle: .intro,
                            colorStyle: .purple623E61,
                            alignment: .center
                        )
                    }
                    .padding(.horizontal, 16.0)
                    
                    Spacer()
                }
                
                VStack(spacing: 16.0) {
                    StyledButtonView(
                        title: "action.proceed".localized(),
                        tapHandler: onContinue
                    )
                    .frame(height: 52.0)
                    
                    StyledButtonView(
                        title: "action.add.caregiver".localized(),
                        style: .secondary,
                        tapHandler: onAddACaregiver
                    )
                    .frame(height: 52.0)
                }
                .padding(.horizontal, 16.0)
            }
        }
        .ignoresSafeArea(edges: model.hasCaregivers ? [] : [.top])
        .opacity(model.revealed ? 1.0 : 0.0)
    }
}

struct PatientRoleScreen_Previews: PreviewProvider {
    private static let model: PatientRoleModel = {
        let model = PatientRoleModel()
        model.reveal()
        
        return model
    }()
    
    static var previews: some View {
        VStack(spacing: 24.0) {
            PatientRoleScreen(
                model: model,
                onAddACaregiver: { /* ... */ },
                onContinue: { /* ... */ },
                onRemoveCaregiver: { _ in /* ... */ }
            )
            
            Button("Toggle caregivers") {
                withAnimation {
                    if model.hasCaregivers {
                        model.updateCaregivers([])
                    } else {
                        let photoURL = URL(string: "https://images.unsplash.com/photo-1512451590339-a3268f0402d9?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=320&q=80")!
                        model.updateCaregivers([
                            IdentityCommonProfileData(id: 1, displayName: "User 1", imageURL: photoURL),
                            IdentityCommonProfileData(id: 2, displayName: "User 2", imageURL: photoURL),
                            IdentityCommonProfileData(id: 3, displayName: "User 3", imageURL: photoURL)
                        ])
                    }
                }
            }
        }
    }
}

private extension IdentityCommonProfileData {
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
