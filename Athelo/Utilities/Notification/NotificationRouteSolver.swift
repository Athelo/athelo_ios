//
//  NotificationRouteSolver.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 20/07/2022.
//

import Foundation
import UserNotifications

typealias NotificationRoute = NotificationRouteSolver.Route

final class NotificationRouteSolver {
    // MARK: - Constants
    private enum UserInfoKeys: String {
        case chatRoomIdentifier = "chat_room_identifier"
        case clickAction = "click_action"
    }
    
    enum NotificationActionType: String {
        case chatNotification = "CHAT_NOTIFICATION"
    }
    
    enum Route {
        case none
        case loginRequired(NavigationRoute)
        case resolved(NavigationRoute)
    }
    
    // MARK: - Public API
    static func actionType(for notification: UNNotification) -> NotificationActionType? {
        actionType(for: notification.request.content.userInfo)
    }
    
    static func actionType(for source: [AnyHashable: Any]) -> NotificationActionType? {
        guard let rawClickAction = source[UserInfoKeys.clickAction.rawValue] as? String else {
            return nil
        }
        
        return NotificationActionType(rawValue: rawClickAction)
    }
    
    static func findRoute(using source: UNNotificationResponse, completion: @escaping (NotificationRoute) -> Void) {
        let userInfo = source.notification.request.content.userInfo
        
        guard let rawClickAction = userInfo[UserInfoKeys.clickAction.rawValue] as? String,
              let clickAction = NotificationActionType(rawValue: rawClickAction) else {
            completion(.none)
            return
        }
        
        switch clickAction {
        case .chatNotification:
            resolveChatNotificationRoute(using: userInfo, completion: completion)
        }
    }
    
    static func resolveChatNotificationRoute(using userInfo: [AnyHashable: Any], completion: @escaping (NotificationRoute) -> Void) {
        if let chatRoomIdentifier = userInfo[UserInfoKeys.chatRoomIdentifier.rawValue] as? String, !chatRoomIdentifier.isEmpty {
            guard IdentityUtility.userData != nil else {
                completion(.loginRequired(.chatRoom(chatRoomIdentifier)))
                return
            }
            
            completion(.resolved(.chatRoom(chatRoomIdentifier)))
        } else {
            completion(.none)
        }
    }
}
