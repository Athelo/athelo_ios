//
//  NotificationUtility.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 20/07/2022.
//

import Combine
import Foundation
import FirebaseMessaging
import UIKit

final class NotificationUtility: NSObject {
    // MARK: - Properties
    private static let instance = NotificationUtility()
    
    private let fcmTokenUpdatedSubject = PassthroughSubject<Void, Never>()
    static var fcmTokenUpdatedPublisher: AnyPublisher<Void, Never> {
        instance.fcmTokenUpdatedSubject.eraseToAnyPublisher()
    }

    private var cancellables: [AnyCancellable] = []

    // MARK: - Initialization
    private override init() {
        super.init()

        sink()
    }

    // MARK: - Public API
    static func handleSilentNotification(userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(.noData)
    }

    static func registerForNotifications(in application: UIApplication) {
        Messaging.messaging().delegate = instance
        UNUserNotificationCenter.current().delegate = instance

        checkNotificationAuthorizationStatus(in: application, requestingStatus: false)
    }

    static func checkNotificationAuthorizationStatus(in application: UIApplication = UIApplication.shared, requestingStatus: Bool = true) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch(settings.authorizationStatus) {
            case .notDetermined:
                guard requestingStatus else {
                    return
                }

                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { isAuthorized, error in
                    if isAuthorized {
                        DispatchQueue.main.async {
                            application.registerForRemoteNotifications()
                        }
                    }
                }
            case .authorized, .ephemeral, .provisional:
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            case .denied:
                break
            @unknown default:
                break
            }
        }
    }

    // MARK: - Sinks
    private func sink() {
//        sinkIntoApplicationStateNotifications()
    }

    private func sinkIntoApplicationStateNotifications() {
        // Added so that in case of auth status switch of .denied -> <any_available> token will be updated.
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { _ in
                NotificationUtility.checkNotificationAuthorizationStatus()
            }.store(in: &cancellables)
    }
}

extension NotificationUtility: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken, !token.isEmpty else {
            return
        }

        debugPrint(#fileID, #function, token)

        Task {
            if try APIEnvironment.setFCMToken(token, force: false) {
                ChatUtility.reconnect()
            }
        }
    }
}

extension NotificationUtility: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(UNNotificationPresentationOptions())
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        NotificationRouteSolver.findRoute(using: response) { route in
            Task {
                await AppRouter.current.navigate(using: route)
            }
            
            completionHandler()
        }
    }
}
