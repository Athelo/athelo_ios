//
//  ChatRoomCollectionViewCell.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 30/06/2022.
//

import UIKit

protocol ChatRoomCellConfigurationData {
    var chatRoomID: Int { get }
    var chatRoomIsMember: Bool { get }
    var chatRoomMembers: [ChatRoomMemberData]? { get }
    var chatRoomName: String { get }
    var chatRoomParticipantCount: Int { get }
}

protocol ChatRoomCollectionViewCellDelegate: AnyObject {
    func chatRoomCollectionViewCell(_ cell: ChatRoomCollectionViewCell, asksToPerformActionForChatRoomWithID chatRoomID: Int)
}

final class ChatRoomCollectionViewCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet private weak var buttonAction: UIButton!
    @IBOutlet private weak var imageViewActionIcon: UIImageView!
    @IBOutlet private weak var imageViewPrimaryAvatar: UIImageView!
    @IBOutlet private weak var imageViewQuaternaryAvatar: UIImageView!
    @IBOutlet private weak var imageViewQuinaryAvatar: UIImageView!
    @IBOutlet private weak var imageViewSecondaryAvatar: UIImageView!
    @IBOutlet private weak var imageViewTertiaryAvatar: UIImageView!
    @IBOutlet private weak var labelActionName: UILabel!
    @IBOutlet private weak var labelChatName: UILabel!
    @IBOutlet private weak var labelParticipantCount: UILabel!
    @IBOutlet private weak var stackViewAction: UIStackView!
    @IBOutlet private weak var viewAvatarContainer: UIView!
    
    // MARK: - Constraints
    @IBOutlet weak var constraintActionStackViewTrailing: NSLayoutConstraint!
    
    // MARK: - Properties
    private(set) var indexPath: IndexPath?
    private(set) var chatRoomID: Int?
    
    private weak var delegate: ChatRoomCollectionViewCellDelegate?
    
    // MARK: - View lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        indexPath = nil
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if buttonAction.frame.contains(point) {
            return buttonAction
        }
        
        return super.hitTest(point, with: event)
    }

    // MARK: - Public API
    func assignDelegate(_ delegate: ChatRoomCollectionViewCellDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Configuration
    private func configure() {
        configureAvatarImageViews()
    }
    
    private func configureAvatarImageViews() {
        [imageViewPrimaryAvatar, imageViewSecondaryAvatar, imageViewTertiaryAvatar, imageViewQuaternaryAvatar, imageViewQuinaryAvatar].forEach({
            $0?.layer.borderColor = UIColor.withStyle(.white).cgColor
            $0?.layer.borderWidth = 2.0
        })
    }
    
    // MARK: - Updates
    private func imageView(for avatarIndex: Int) -> UIImageView? {
        switch avatarIndex {
        case 0:
            return imageViewPrimaryAvatar
        case 1:
            return imageViewSecondaryAvatar
        case 2:
            return imageViewTertiaryAvatar
        case 3:
            return imageViewQuaternaryAvatar
        case 4:
            return imageViewQuinaryAvatar
        default:
            break
        }
        
        return nil
    }
    
    // MARK: - Actions
    @IBAction private func actionButtonTapped(_ sender: Any) {
        guard let chatRoomID = chatRoomID else {
            return
        }
        
        delegate?.chatRoomCollectionViewCell(self, asksToPerformActionForChatRoomWithID: chatRoomID)
    }
}

// MARK: - Protocol conformance
// MARK: ConfigurableCell
extension ChatRoomCollectionViewCell: ConfigurableCell {
    typealias DataType = ChatRoomCellConfigurationData
    
    func configure(_ item: DataType, indexPath: IndexPath) {
        self.indexPath = indexPath
        self.chatRoomID = item.chatRoomID
        
        if !item.chatRoomName.isEmpty {
            labelChatName.text = item.chatRoomName
            labelChatName.isHidden = false
        } else {
            labelChatName.isHidden = true
        }
        
        if let chatRoomMembers = item.chatRoomMembers, !chatRoomMembers.isEmpty {
            for imageViewIndex in (0...4) {
                guard let imageView = imageView(for: imageViewIndex) else {
                    continue
                }
                
                if let member = chatRoomMembers[safe: imageViewIndex] {
                    imageView.displayLoadableImage(member.avatarImage(in: imageView.bounds.size))
                    imageView.isHidden = false
                } else {
                    imageView.isHidden = true
                }
            }
            
            viewAvatarContainer.isHidden = false
        } else {
            viewAvatarContainer.isHidden = true
        }
        
        if item.chatRoomParticipantCount > 1 {
            labelParticipantCount.text = "community.participantcount.multiple".localized(arguments: [item.chatRoomParticipantCount])
        } else if item.chatRoomParticipantCount == 1 {
            labelParticipantCount.text = "community.participantcount.one".localized()
        } else {
            labelParticipantCount.text = "community.participantcount.none".localized()
        }
        
        if item.chatRoomIsMember {
            imageViewActionIcon.image = UIImage(named: "chatCheckmark")
            imageViewActionIcon.tintColor = .withStyle(.lightOlivaceous)
            imageViewActionIcon.isHidden = false
            
            labelActionName.text = "community.chatcell.member".localized()
            labelActionName.textColor = .withStyle(.lightOlivaceous)
            
            buttonAction.isHidden = true
            
            constraintActionStackViewTrailing.constant = 0.0
        } else {
            imageViewActionIcon.isHidden = true
            
            labelActionName.text = "action.opencommunity".localized()
            labelActionName.textColor = .withStyle(.purple623E61)
            
            buttonAction.isHidden = false
            
            constraintActionStackViewTrailing.constant = 8.0
        }
    }
}
