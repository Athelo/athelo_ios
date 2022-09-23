//
//  Router.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 31/05/2022.
//

import Foundation
import UIKit

protocol RouterProtocol {
    /* ... */
}

protocol Router: RouterProtocol {
    var navigationController: UINavigationController? { get }

    init(navigationController: UINavigationController)
}

protocol TabRouter: RouterProtocol {
    var tabBarController: UITabBarController? { get }

    init(tabBarController: UITabBarController)
}

protocol Routable {
    associatedtype RouterType = RouterProtocol

    func assignRouter(_ router: RouterType)
}
