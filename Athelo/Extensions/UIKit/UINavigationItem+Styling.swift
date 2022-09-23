//
//  UINavigationItem+Styling.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 12/06/2022.
//

import Combine
import UIKit

extension UINavigationItem {
    func displayAppLogo() {
        let logoImageView = UIImageView(image: UIImage(named: "logoSmallHorizontal"))
        
        logoImageView.contentMode = .scaleAspectFit
        
        titleView = logoImageView
    }
    
    func displayUserAvatar(with router: (UserProfileRoutable & AnyObject)?) -> AnyCancellable {
        let avatarView = UserAvatarImageView.instantiate()
        let cancellable = avatarView.tapPublisher
            .sink { [weak router = router] in
                router?.navigateToUserProfile()
            }
        
        let navBarItem = UIBarButtonItem(customView: avatarView)
        rightBarButtonItem = navBarItem
        
        return cancellable
    }
}
