//
//  BaseTabBarController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 09/06/2022.
//

import UIKit

class BaseTabBarController: UITabBarController {
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureTabBar()
    }
    
    private func configureTabBar() {
        tabBar.backgroundColor = .withStyle(.white)
        tabBar.unselectedItemTintColor = .withStyle(.gray)
        tabBar.shadowImage = UIImage()
        
        let fillRect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        tabBar.backgroundImage = UIGraphicsImageRenderer(size: fillRect.size).image(actions: { context in
            context.cgContext.setFillColor(UIColor.withStyle(.white).cgColor)
            context.fill(fillRect)
        })
    }
}
