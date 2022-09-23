//
//  LocalNotificationData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 25/07/2022.
//

import Combine
import Foundation
import UIKit

enum LocalNotificationData {
    enum UserInfoKey: String {
        case newsData
        case summaryData
    }
    
    case newsFavoriteStateUpdated
    case symptomSummaryDataUpdated
    
    private var notificationName: Notification.Name {
        switch self {
        case .newsFavoriteStateUpdated:
            return .init(rawValue: "athelo.newsFavoriteStateUpdated")
        case .symptomSummaryDataUpdated:
            return .init(rawValue: "athelo.symptomSummaryDataUpdated")
        }
    }
    
    static func postNotification(_ notification: LocalNotificationData, parameters: [UserInfoKey: Any]? = nil) {
        var userInfo: [String: Any] = [:]
        
        if let parameters = parameters {
            for (key, value) in parameters {
                userInfo[key.rawValue] = value
            }
        }
        
        NotificationCenter.default.post(name: notification.notificationName, object: nil, userInfo: userInfo)
    }
    
    static func publisher(for notification: LocalNotificationData) -> AnyPublisher<[AnyHashable: Any]?, Never> {
        NotificationCenter.default.publisher(for: notification.notificationName)
            .map({ $0.userInfo })
            .eraseToAnyPublisher()
    }
}

extension Dictionary where Key == AnyHashable {
    func value(for userInfoKey: LocalNotificationData.UserInfoKey) -> Any? {
        self[userInfoKey.rawValue]
    }
}
