//
//  ContactData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 20/03/2023.
//

import Foundation

protocol ContactData: RendererAvatarSource {
    var contactDisplayName: String? { get }
    var contactID: Int { get }
    var contactRelationName: String? { get }
    var contactPhoto: ImageData? { get }
}

extension ContactData {
    var rendererAvatarDisplayName: String? {
        contactDisplayName
    }
}
