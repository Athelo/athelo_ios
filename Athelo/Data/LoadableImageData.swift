//
//  AvatarImageType.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 09/06/2022.
//

import Foundation
import UIKit

enum LoadableImageData: Hashable {
    case image(UIImage)
    case url(URL)
}

extension ChatRoomMemberData {
    func avatarImage(in size: CGSize, borderStyle: RendererUtility.BorderStyle = .ellipse) -> LoadableImageData {
        if let imageURL = photo?.fittingImageURL(forSize: size) {
            return .url(imageURL)
        }
        
        return .image(RendererUtility.renderAvatarPlaceholder(for: self, size: size, borderStyle: borderStyle))
    }
}

extension IdentityProfileData {
    func avatarImage(in size: CGSize, borderStyle: RendererUtility.BorderStyle = .ellipse) -> LoadableImageData {
        if let imageURL = photo?.fittingImageURL(forSize: size) {
            return .url(imageURL)
        }
        
        return .image(RendererUtility.renderAvatarPlaceholder(for: self, size: size, borderStyle: borderStyle))
    }
}
