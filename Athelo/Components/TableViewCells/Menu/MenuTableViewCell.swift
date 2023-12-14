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
        case .messages:
            return UIImage(named: "envelope")
        case .myCaregivers:
            return UIImage(named: "handHeart")
        case .myProfile:
            return UIImage(named: "person")
        case .mySymptoms:
            return UIImage(named: "monitor")
        case .myWards:
            return UIImage(named: "handHeart")
        case .sendFeedback:
            return UIImage(named: "chatHeart")
            // Restore this option once Ask Athelo will be added back to menu.
//            return UIImage(named: "paperPlane")
        case .settings:
            return UIImage(named: "sliders")
        }
    }
}
