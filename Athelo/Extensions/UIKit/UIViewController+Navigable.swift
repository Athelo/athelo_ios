//
//  UIViewController+Navigable.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 31/05/2022.
//

import Foundation
import UIKit

enum StoryboardScene: String {
    case activity
    case authentication
    case community
    case contacts
    case feedback
    case faq
    case home
    case intro
    case menu
    case news
    case appointment
    case profile
    case role
    case settings
    case sleep
    case splash
    case symptom
    case watch
    case web

    var storyboardName: String {
        return rawValue.capitalized
    }
}

protocol Navigable {
    static var storyboardScene: StoryboardScene { get }
}

protocol Configurable {
    associatedtype ConfigurationDataType

    func assignConfigurationData(_ configurationData: ConfigurationDataType)
}

extension UIViewController {
    static var className: String { return String(describing: self) }
}

extension Navigable where Self: UIViewController {
    static func viewController() -> Self {
        viewControllerInstance()
    }

    static func viewController(configurationData: Self.ConfigurationDataType) -> Self where Self: Configurable {
        let viewController = viewControllerInstance()

        viewController.assignConfigurationData(configurationData)

        return viewController
    }

    static func viewController(router: Self.RouterType) -> Self where Self: Routable {
        let viewController = viewControllerInstance()

        viewController.assignRouter(router)

        return viewController
    }

    static func viewController(configurationData: Self.ConfigurationDataType, router: Self.RouterType) -> Self where Self: Configurable & Routable {
        let viewController = viewControllerInstance()

        viewController.assignConfigurationData(configurationData)
        viewController.assignRouter(router)

        return viewController
    }

    fileprivate static func viewControllerInstance() -> Self {
        let storyboardName = storyboardScene.storyboardName

        guard let viewController = UIStoryboard(name: storyboardName, bundle: nil).instantiateViewController(identifier: className) as? Self else {
            fatalError("ViewController '\(className)' doesn't exist in '\(storyboardName)'")
        }

        return viewController
    }
}
