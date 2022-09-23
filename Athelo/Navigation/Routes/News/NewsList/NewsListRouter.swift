//
//  NewsListRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 04/07/2022.
//

import Foundation
import UIKit

final class NewsListRouter: NewsRouter, UserProfileRoutable {
    // MARK: - Public API
    func navigateToNewsDetails(using configurationData: ModelConfigurationData<NewsData>) {
        guard let navigationController = navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        let router = NewsDetailsRouter(navigationController: navigationController, newsUpdateEventSubject: newsUpdateEventsSubject)
        let viewController = NewsDetailsViewController.viewController(configurationData: configurationData, router: router)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
