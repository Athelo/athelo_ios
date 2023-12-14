//
//  WardListModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 05/09/2022.
//

import Foundation
import SwiftUI

final class ContactListModel: ObservableObject {
    @Published private(set) var contacts: [ContactData]
    
    init(contacts: [ContactData]) {
        self.contacts = contacts
    }
    
    func removeContact(_ contact: ContactData, animated: Bool = false) {
        guard let contactIndex = contacts.firstIndex(where: { $0.contactID == contact.contactID }) else {
            return
        }
        
        _ = withExplicitAnimation(animated) {
            contacts.remove(at: contactIndex)
        }
    }
    
    func updateContacts(_ contacts: [ContactData], animated: Bool = false) {
        withExplicitAnimation(animated) {
            self.contacts = contacts
        }
    }
    
    func updateContact(_ contact: ContactData, animated: Bool = false) {
        var contacts = self.contacts
        if let contactIndex = contacts.firstIndex(where: { $0.contactID == contact.contactID }) {
            contacts[contactIndex] = contact
        } else {
            contacts.append(contact)
        }
        
        withExplicitAnimation(animated) {
            self.contacts = contacts
        }
    }
}
