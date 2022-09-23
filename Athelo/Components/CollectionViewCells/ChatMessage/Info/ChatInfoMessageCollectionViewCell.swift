//
//  ChatInfoMessageCollectionViewCell.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 14/07/2022.
//

import SwiftDate
import UIKit

final class ChatInfoMessageCollectionViewCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet private weak var labelMessage: UILabel!
}

// MARK: - Protocol conformance
// MARK: ConfigurableCell
extension ChatInfoMessageCollectionViewCell: ConfigurableCell {
    enum ConfigurationData {
        case date(Date)
        case message(MessagingChatMessage)
    }
    
    typealias DataType = ConfigurationData
    
    func configure(_ item: ConfigurationData, indexPath: IndexPath) {
        labelMessage.text = item.itemDescription
    }
}

private extension ChatInfoMessageCollectionViewCell.ConfigurationData {
    var itemDescription: String {
        switch self {
        case .date(let date):
            if let difference = date.difference(in: .day, from: Date()) {
                switch difference {
                case 0:
                    return "date.today".localized()
                case 1:
                    return "date.yesterday".localized()
                default:
                    return date.toString(.date(.long))
                }
            } else {
                return date.toString(.date(.long))
            }
        case .message(let message):
            return message.message ?? ""
        }
    }
}
