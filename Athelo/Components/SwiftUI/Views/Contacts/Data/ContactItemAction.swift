//
//  ContactItemAction.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 20/03/2023.
//

import Foundation
import UIKit

struct ContactItemAction: Identifiable {
    private let uuid: UUID = UUID()
    var id: UUID {
        uuid
    }
    
    let icon: UIImage
    let action: (ContactData) -> Void
}
