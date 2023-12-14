//
//  CaregiverRoleScreen.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 16/01/2023.
//

import SwiftUI

struct CaregiverRoleScreen: View {
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
    
    @ObservedObject private(set) var model: CaregiverRoleModel
    
    private(set) var onAddAWard: () -> Void
    private(set) var onContinue: (ContactData) -> Void
    
    var body: some View {
        ZStack {
            if !model.hasPatients {
                VStack {
                    BottomClippedGradientView(
                        imageData: BottomClippedGradientViewImageData(
                            image: UIImage(named: "caregiver")!,
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
                if model.hasPatients {
                    StyledText(
                        "role.caregiver.mgmt.header".localized(),
                        textStyle: .intro,
                        colorStyle: .purple623E61,
                        alignment: .center
                    )
                    .padding(.horizontal, 16.0)
                    .padding(.top, 24.0)
                    
                    ScrollView {
                        LazyVStack(spacing: 24.0) {
                            ForEach(model.patients, id: \.contactID) { patient in
                                SelectPatientView(
                                    patientData: patient,
                                    isSelected: Binding(
                                        get: { patient.contactID == model.selectedPatient?.contactID },
                                        set: { _ in /* ... */ }
                                    )
                                )
                                .onTapGesture {
                                    withAnimation {
                                        model.selectPatient(patient)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16.0)
                        .padding(.top, 16.0)
                    }
                } else {
                    Spacer()
                        .aspectRatio(Constants.headerRatio, contentMode: .fit)
                    
                    Group {
                        StyledText(
                            "role.caregiver.mgmt.nodata".localized(),
                            textStyle: .headline20,
                            colorStyle: .black,
                            alignment: .center
                        )
                        
                        StyledText(
                            "role.caregiver.mgmt.prompt".localized(),
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
                        title: "action.proceed".localized()
                    ) {
                        if let selectedPatient = model.selectedPatient {
                            onContinue(selectedPatient)
                        }
                    }
                    .opacity(model.selectedPatient != nil ? 1.0 : 0.5)
                    .frame(height: 52.0)
                    
                    StyledButtonView(
                        title: "action.add.patient".localized(),
                        style: .secondary,
                        tapHandler: onAddAWard
                    )
                    .frame(height: 52.0)
                }
                .padding(.horizontal, 16.0)
            }
        }
        .ignoresSafeArea(edges: model.hasPatients ? [] : [.top])
        .opacity(model.revealed ? 1.0 : 0.0)
    }
}

struct CaregiverRoleScreen_Previews: PreviewProvider {
    private static let model: CaregiverRoleModel = {
        let model = CaregiverRoleModel()
        model.reveal()
        
        let photoURL = URL(string: "https://images.unsplash.com/photo-1512451590339-a3268f0402d9?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=320&q=80")!
        
//        model.updatePatients([
//            IdentityCommonProfileData(id: 1, displayName: "User 1", imageURL: photoURL),
//            IdentityCommonProfileData(id: 2, displayName: "User 2", imageURL: photoURL),
//            IdentityCommonProfileData(id: 3, displayName: "User 3", imageURL: photoURL)
//        ])
        
        return model
    }()
    
    static var previews: some View {
        VStack(spacing: 24.0) {
            CaregiverRoleScreen(
                model: model,
                onAddAWard: { /* ... */ },
                onContinue: { _ in /* ... */ }
            )
            
            Button("Toggle Patients") {
                withAnimation {
                    if model.hasPatients {
                        model.updatePatients([])
                    } else {
                        let photoURL = URL(string: "https://images.unsplash.com/photo-1512451590339-a3268f0402d9?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=320&q=80")!
                        model.updatePatients([
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
