//
//  ChatOutgoingMessageCollectionViewCell.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 12/07/2022.
//

import SwiftDate
import UIKit

final class ChatOutgoingMessageCollectionViewCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet private weak var labelMessageBody: UILabel!
    @IBOutlet private weak var labelMessageDate: UILabel!
    @IBOutlet private weak var labelSenderName: UILabel!
    @IBOutlet private weak var stackViewContent: UIStackView!
    @IBOutlet private weak var stackViewMessage: UIStackView!
    @IBOutlet private weak var viewDateContainer: UIView!
    @IBOutlet private weak var viewMessageBackground: UIView!
    
    // MARK: - Constraints
    @IBOutlet private weak var constraintStackViewContentBottom: NSLayoutConstraint!
    @IBOutlet private weak var constraintStackViewContentTop: NSLayoutConstraint!
    @IBOutlet private weak var constraintViewMessageBackgroundTop: NSLayoutConstraint!
}

// MARK: - Protocol conformance
// MARK: ConfigurableCell
extension ChatOutgoingMessageCollectionViewCell: ConfigurableCell {
    typealias DataType = ChatMessageCellDecorationData
    
    func configure(_ item: ChatMessageCellDecorationData, indexPath: IndexPath) {
        if item.displaysSenderName {
            labelSenderName.text = "community.sender.me".localized()
            labelSenderName.isHidden = false
            
            self.constraintStackViewContentTop.constant = 4.0
            self.constraintViewMessageBackgroundTop.constant = -4.0
        } else {
            labelSenderName.isHidden = true
            
            self.constraintStackViewContentTop.constant = 16.0
            self.constraintViewMessageBackgroundTop.constant = -16.0
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
