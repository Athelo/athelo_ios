//
//  SelectContactView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 24/03/2023.
//

import SwiftUI

struct SelectContactView: View {
    @State private var contentHeight: CGFloat = 0.0
    
    @State private var selectedContact: ContactData?
    let contacts: [ContactData]
    
    let onContactSelected: (ContactData) -> Void
    let onCancel: () -> Void
    
    init(contacts: [ContactData], selectedContact: ContactData? = nil, onContactSelected: @escaping (ContactData) -> Void, onCancel: @escaping () -> Void) {
        self.contacts = contacts
        _selectedContact = State(initialValue: selectedContact)
    
        self.onContactSelected = onContactSelected
        self.onCancel = onCancel
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            GeometryReader { proxy in
                VStack(spacing: 12.0) {
                    StyledText(
                        "Select your ward",
                        textStyle: .headline20,
                        colorStyle: .purple623E61,
                        alignment: .leading
                    )
                    .padding(.top, 8.0)
                    .padding(.horizontal, 16.0)
                    
                    ScrollView {
                        LazyVStack(spacing: 0.0) {
                            ForEach(contacts, id: \.contactID) { contact in
                                VStack(spacing: 0.0) {
                                    HStack(spacing: 24.0) {
                                        StyledImageView(
                                            imageData: contact.avatarImage(in: CGSize(width: 48.0, height: 48.0), placeholderStyle: .initials(.roundedRect(15.0)))
                                        )
                                        .frame(width: 48.0, height: 48.0)
                                        .roundedCorners(radius: 15.0)
                                        
                                        StyledText(
                                            contact.contactDisplayName ?? "Your Ward",
                                            textStyle: .subheading,
                                            colorStyle: .gray,
                                            alignment: .leading
                                        )
                                        
                                        RadioStateView(isSelected: Binding(
                                            get: { contact.contactID == selectedContact?.contactID },
                                            set: { _ in /* ... */ }
                                        ))
                                        .frame(width: 24.0, height: 24.0)
                                    }
                                    .onTapGesture {
                                        withAnimation {
                                            selectedContact = contact
                                        }
                                    }
                                    
                                    Rectangle()
                                        .fill(Color(UIColor.withStyle(.lightGray).cgColor))
                                        .opacity(0.2)
                                        .frame(height: 1.0)
                                        .padding(.vertical, 6.0)
                                }
                            }
                            .padding(.horizontal, 16.0)
                        }
                        .getSize { contentSize in
                            self.contentHeight = contentSize.height
                        }
                    }
                    .frame(height: min(proxy.size.height - (150.0 + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom), contentHeight))
                    
                    HStack {
                        StyledButtonView(title: "Cancel", style: .secondary) {
                            onCancel()
                        }
                        .frame(idealWidth: 100.0, maxWidth: max(100.0, proxy.size.width / 4.0))
                        
                        Spacer()
                        
                        StyledButtonView(title: "Switch", style: .main) {
                            if let selectedContact = self.selectedContact {
                                onContactSelected(selectedContact)
                            }
                        }
                        .frame(idealWidth: 100.0, maxWidth: max(100.0, proxy.size.width / 4.0))
                    }
                    .frame(height: 52.0)
                    .padding(.top, 12.0)
                    .padding(.horizontal, 16.0)
                }
                .padding(.vertical, 16.0)
                .background(
                    Rectangle()
                        .fill(Color(UIColor.withStyle(.background).cgColor))
                )
                .roundedCorners(radius: 30.0)
                .padding(.horizontal, 16.0)
                .frame(height: proxy.size.height)
                .styledShadow()
            }
        }
    }
}

struct SelectContactView_Previews: PreviewProvider {
    static var previews: some View {
        SelectContactView(
            contacts: IdentityCommonProfileData.samples,
            onContactSelected: { _ in /* ... */ },
            onCancel: { /* ... */ }
        )
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
