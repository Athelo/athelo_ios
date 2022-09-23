//
//  WebContentRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 21/06/2022.
//

import Foundation
import SafariServices

protocol WebContentRouter: RouterProtocol {
    func displayURL(_ configurationData: WebViewController.ConfigurationData)
    func displayURL(_ url: URL)
}

extension Router where Self: WebContentRouter {
    @MainActor func displayURL(_ configurationData: WebViewController.ConfigurationData) {
        if configurationData.url.scheme == "mailto" {
            if UIApplication.shared.canOpenURL(configurationData.url) {
                UIApplication.shared.open(configurationData.url)
            }
            return
        }
        
        guard let navigationController = navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        let viewController = WebViewController.viewController(configurationData: configurationData)

        navigationController.present(viewController, animated: true)
    }
    
    @MainActor func displayURL(_ url: URL) {
        displayURL(.init(url: url))
    }
}


