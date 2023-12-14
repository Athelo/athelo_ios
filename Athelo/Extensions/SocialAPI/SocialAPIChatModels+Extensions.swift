//
//  NetworkingChatModels+Extensions.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 12/07/2022.
//

<<<<<<< HEAD:Athelo/Extensions/Networking/NetworkingChatModels+Extensions.swift
import Foundation
import UIKit

extension MessagingChatMessageUserData: RendererAvatarSource {
=======
import SocialAPI
import Foundation
import UIKit

extension SocialChatMessageUserData: RendererAvatarSource {
>>>>>>> feature/caregivers:Athelo/Extensions/SocialAPI/SocialAPIChatModels+Extensions.swift
    var rendererAvatarDisplayName: String? {
        displayName
    }
}

<<<<<<< HEAD:Athelo/Extensions/Networking/NetworkingChatModels+Extensions.swift
extension MessagingChatMessage {
=======
extension SocialChatMessage {
>>>>>>> feature/caregivers:Athelo/Extensions/SocialAPI/SocialAPIChatModels+Extensions.swift
    var messageID: String {
        "\(chatRoomIdentifier)-\(userIdentifier)-\(timestamp)"
    }
}

<<<<<<< HEAD:Athelo/Extensions/Networking/NetworkingChatModels+Extensions.swift
extension NetworkingImageData {
=======
extension SocialImageData {
>>>>>>> feature/caregivers:Athelo/Extensions/SocialAPI/SocialAPIChatModels+Extensions.swift
    func fittingImageURL(forSize size: CGSize) -> URL? {
        fittingImageURL(forSizeInPixels: max(size.width, size.height))
    }
    
    func fittingImageURL(forSizeInPixels pixels: CGFloat = 0.0) -> URL? {
        guard pixels >= 0 else {
            return nil
        }
        
        let expectedSize = pixels * UIScreen.main.scale
        
        switch expectedSize {
        case _ where expectedSize <= 50:
            if let url = image50px {
                return url
            }
            fallthrough
        case _ where expectedSize <= 100:
            if let url = image100px {
                return url
            }
            fallthrough
        case _ where expectedSize <= 125:
            if let url = image125px {
                return url
            }
            fallthrough
        case _ where expectedSize <= 250:
            if let url = image250px {
                return url
            }
            fallthrough
        case _ where expectedSize <= 500:
            if let url = image500px {
                return url
            }
            fallthrough
        default:
            return image
        }
    }
}
