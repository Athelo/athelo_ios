//
//  NewsRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 07/07/2022.
//

import Combine
import Foundation
import UIKit

class NewsRouter: Router {
    // MARK: - Properties
    weak var navigationController: UINavigationController?
    let newsUpdateEventsSubject: NewsUpdateEventsSubject
    
    // MARK: - Initialization
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.newsUpdateEventsSubject = NewsUpdateEventsSubject()
    }
    
    init(navigationController: UINavigationController, newsUpdateEventSubject: NewsUpdateEventsSubject?) {
        self.navigationController = navigationController
        self.newsUpdateEventsSubject = newsUpdateEventSubject ?? NewsUpdateEventsSubject()
    }
}

// MARK: - Helper extensions
extension NewsRouter {
    typealias NewsUpdateEventsSubject = PassthroughSubject<UpdateEvent, Never>
    
    enum UpdateEvent {
//        case favoriteStatusUpdated(NewsData)
    }
}
