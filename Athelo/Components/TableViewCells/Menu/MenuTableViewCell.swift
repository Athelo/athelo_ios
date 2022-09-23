//
//  MenuTableViewCell.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 09/06/2022.
//

import UIKit

final class MenuTableViewCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet private weak var imageViewIcon: UIImageView!
    @IBOutlet private weak var labelOptionName: UILabel!
}

// MARK: - Protocol conformance
// MARK: ConfigurableCell
extension MenuTableViewCell: ConfigurableCell {
    typealias DataType = MenuOption
    
    func configure(_ item: DataType, indexPath: IndexPath) {
        imageViewIcon.image = item.optionIcon
        labelOptionName.text = item.optionName
    }
}

// MARK: - Helper extensions
private extension MenuOption {
    var optionIcon: UIImage? {
        switch self {
        case .askAthelo:
            return UIImage(named: "chatHeart")
        case .connectSmartWatch:
            return UIImage(named: "watch")
        case .inviteACaregiver:
            return UIImage(named: "addContact")
        case .messages:
            return UIImage(named: "envelope")
        case .myCaregivers:
            return UIImage(named: "handHeart")
        case .myProfile:
            return UIImage(named: "person")
        case .mySymptoms:
            return UIImage(named: "monitor")
        case .sendFeedback:
            return UIImage(named: "paperPlane")
        case .settings:
            return UIImage(named: "sliders")
        }
    }
}
