//
//  WardListView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 05/09/2022.
//

import SwiftUI

struct ContactListView: View {
    @ObservedObject var model: ContactListModel
    let actions: [ContactItemAction]?
    let additionalTopContentOffset: CGFloat
    
    let onTap: ((ContactData) -> Void)?
    
    init(model: ContactListModel, actions: [ContactItemAction]? = nil, additionalTopContentOffset: CGFloat? = nil, onTap: ((ContactData) -> Void)? = nil) {
        self.model = model
        self.actions = actions
        self.onTap = onTap
        self.additionalTopContentOffset = max(additionalTopContentOffset ?? 0.0, 0.0)
    }
    
    var body: some View {
        FadingScrollView {
            LazyVStack(spacing: 24.0) {
                ForEach(model.contacts, id: \.contactID) { contact in
                    ContactItemView(personData: contact, actions: actions, onTap: onTap)
                        .frame(minHeight: 104.0, alignment: .center)
                }
            }
            .padding(.horizontal, 16.0)
            .padding(.top, additionalTopContentOffset)
            .padding(.vertical, 24.0)
        }
    }
}

struct ContactListView_Previews: PreviewProvider {
    static let model = ContactListModel(contacts: [])
    
    static var previews: some View {
        VStack(alignment: .center) {
            ContactListView(
                model: model,
                actions: [
                    .init(icon: .init(named: "envelopeSolid")!, action: { _ in /* ... */ }),
                    .init(icon: .init(named: "trashBinSolid")!, action: { _ in /* ... */ })
                ]
            )
            
            Divider()
            
            HStack {
                Button("Add new Ward") {
                    let id = model.contacts.count + 1
                    withAnimation {
                        model.updateContact(IdentityProfileData(
                            id: id,
                            firstName: "\(Int.random(in: 0...100000))",
                            lastName: "\(Int.random(in: 0...100000))",
                            imageURL: URL(string: "https://images.unsplash.com/photo-1512451590339-a3268f0402d9?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=320&q=80")!
                        ))
                    }
                }
                
                Divider()
                    .frame(height: 12.0)
                
                Button("Scramble") {
                    withAnimation {
                        model.updateContacts(model.contacts.shuffled())
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

private extension IdentityProfileData {
    init(id: Int, firstName: String, lastName: String, imageURL: URL) {
        self.commonProfileData = IdentityCommonProfileData(
            id: id,
            displayName: "\(firstName) \(lastName)",
            imageURL: imageURL
        )
        self.dateOfBirth = nil
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
