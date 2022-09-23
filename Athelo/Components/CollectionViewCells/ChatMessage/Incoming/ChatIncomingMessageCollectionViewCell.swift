//
//  ChatMessageCollectionViewCell.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 12/07/2022.
//

import SwiftDate
import UIKit

final class ChatIncomingMessageCollectionViewCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet private weak var imageViewAvatar: UIImageView!
    @IBOutlet private weak var labelMessageBody: UILabel!
    @IBOutlet private weak var labelMessageDate: UILabel!
    @IBOutlet private weak var labelSenderName: UILabel!
    @IBOutlet private weak var stackViewContent: UIStackView!
    @IBOutlet private weak var stackViewMessage: UIStackView!
    @IBOutlet private weak var viewDateContainer: UIView!
    @IBOutlet private weak var viewMessageBackground: UIView!
    
    // MARK: - Constraints
    @IBOutlet private weak var constraintStackViewContentBottom: NSLayoutConstraint!
    @IBOutlet private weak var constraintStackViewContentLeading: NSLayoutConstraint!
    @IBOutlet private weak var constraintStackViewContentTrailing: NSLayoutConstraint!
    @IBOutlet private weak var constraintStackViewMessageTop: NSLayoutConstraint!
    @IBOutlet private weak var constraintViewMessageBackgroundTop: NSLayoutConstraint!
}

// MARK: - Protocol conformance
// MARK: ConfigurableCell
extension ChatIncomingMessageCollectionViewCell: ConfigurableCell {
    typealias DataType = ChatMessageCellDecorationData
    
    func configure(_ item: ChatMessageCellDecorationData, indexPath: IndexPath) {
        if item.displaysAvatar {
            imageViewAvatar.image = nil
            imageViewAvatar.alpha = 1.0
            
            if let avatarURL = item.message.userData?.photo?.fittingImageURL(forSizeInPixels: 30.0) {
                var placeholder: UIImage?
                if let userData = item.message.userData {
                    placeholder = RendererUtility.renderAvatarPlaceholder(for: userData, size: imageViewAvatar.frame.size)
                }
                
                imageViewAvatar.displayLoadableImage(.url(avatarURL), placeholder: placeholder)
            } else if let userData = item.message.userData {
                imageViewAvatar.image = RendererUtility.renderAvatarPlaceholder(for: userData, size: imageViewAvatar.frame.size)
            }
        } else {
            imageViewAvatar.alpha = 0.0
        }
        
        if item.displaysSenderName,
           let senderName = item.message.userData?.displayName, !senderName.isEmpty {
            labelSenderName.text = senderName
            labelSenderName.isHidden = false
            
            constraintStackViewMessageTop.constant = 4.0
            constraintViewMessageBackgroundTop.constant = -4.0
        } else {
            labelSenderName.isHidden = true
            
            constraintStackViewMessageTop.constant = 16.0
            constraintViewMessageBackgroundTop.constant = -16.0
        }
        
        labelMessageBody.text = item.message.message
        
        if item.displaysDate {
            let date = Date(chatTimestamp: item.message.timestamp)
            labelMessageDate.text = date.in(region: .current).toString(.time(.short))
            
            viewDateContainer.isHidden = false
            
            constraintStackViewContentBottom.constant = 0.0
        } else {
            viewDateContainer.isHidden = true
            
            constraintStackViewContentBottom.constant = 16.0
        }
    }
}

