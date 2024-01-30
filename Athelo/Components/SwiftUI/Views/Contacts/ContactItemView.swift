//
//  WardItemView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 05/09/2022.
//

import SwiftUI

struct ContactItemView: View {
    let personData: any ContactData
    let actions: [ContactItemAction]?
    
    let onTap: ((any ContactData) -> Void)?
    
    var body: some View {
        HStack(alignment: .center, spacing: 16.0) {
            StyledImageView(
                imageData: personData.avatarImage(
                    in: .init(width: 72.0, height: 72.0),
                    placeholderStyle: .initials(.roundedRect(20.0))
                ),
                contentMode: .scaleAspectFit
            )
            .frame(width: 72.0, height: 72.0, alignment: .center)
            .cornerRadius(20.0)
            
            VStack(spacing: 8.0) {
                StyledText(
                    personData.contactDisplayName ?? "",
                    textStyle: .subheading,
                    colorStyle: .gray,
                    alignment: .leading
                )
                .lineLimit(1)
                
                StyledText(
                    "Friend",
                    textStyle: .body,
                    colorStyle: .gray,
                    alignment: .leading
                )
                .lineLimit(1)
            }
            
            if let actions {
                VStack {
                    ForEach(actions) { action in
                        Button {
                            action.action(personData)
                        } label: {
                            Image(uiImage: action.icon)
                                .scaledToFit()
                                .padding(8.0)
                                .frame(width: 38.0, height: 38.0)
                                .styledBackground(.withStyle(.purple988098).withAlphaComponent(0.17))
                                .cornerRadius(8.0)
                        }
                    }
                }
            }
        }
        .padding(16.0)
        .styledBackground(.withStyle(.white))
        .cornerRadius(30.0)
        .styledShadow()
    }
}

struct ContactItemView_Previews: PreviewProvider {
    static var previews: some View {
        ContactItemView(
            personData: IdentityProfileData(
                id: 1,
                firstName: "Amina",
                lastName: "Harris",
                imageURL: URL(string: "https://images.unsplash.com/photo-1512451590339-a3268f0402d9?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=320&q=80")!),
            actions: [
                .init(icon: .init(named: "envelopeSolid")!, action: { _ in /* ... */ }),
                .init(icon: .init(named: "trashBinSolid")!, action: { _ in /* ... */ })
            ],
            onTap: { _ in /* ... */ }
        )
            .padding()
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

private extension IdentityProfileData {
    init(id: Int, firstName: String, lastName: String, imageURL: URL) {
        self.commonProfileData = IdentityCommonProfileData(
            id: id,
            displayName: "\(firstName) \(lastName)",
            imageURL: imageURL
        )
        self.birthday = nil
        self.email = nil
        self.firstName = firstName
        self.hasFitbitUserProfile = nil
        self.lastName = lastName
        self.isFriend = nil
        self.personTags = nil
        self.phoneNumber = nil
        self.relationStatus = nil
        self.user = nil
    }
}

