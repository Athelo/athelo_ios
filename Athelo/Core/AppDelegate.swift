//
//  AppDelegate.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 30/05/2022.
//

import FirebaseCore
import BranchSDK
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    // Override point for customization after application launch.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Branch.setUseTestBranchKey(true)
          // Listener for Branch deep link data
        Branch.getInstance().initSession(launchOptions: launchOptions) { (params, error) in
            if let deeplinkPath = params?["$deeplink_path"]{
                UserDefaults.standard.setValue(deeplinkPath, forKey: "deepLinkPath")
                UserDefaults.standard.synchronize()
            }
        }
        configureNetworkingAPI()
        
        FirebaseApp.configure()
        ImageCacheUtility.setupCachingRules()
        NotificationUtility.registerForNotifications(in: application)
        
        #if DEBUG
        UserDefaults.standard.set(true, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        #endif
        
        return true
    }

    // MARK: UISceneSession Lifecycle
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        /* ... */
    }
    
    // MARK: Configuration
    private func configureNetworkingAPI() {
        let configuration = APIConfiguration(
            applicationIdentifier: try! ConfigurationReader.configurationValue(for: .apiIdentifier),
            chatIdentifier: try! ConfigurationReader.configurationValue(for: .chatIdentifier),
            appVersion: Bundle.main.appBuild,
            servicePath: "https://" + (try! ConfigurationReader.configurationValue(for: .apiURL)),
            chatServicePath: "https://" + (try! ConfigurationReader.configurationValue(for: .chatURL))
        )
        
        APIEnvironment.applyConfiguration(configuration)
    }
}

//Branch functions
extension AppDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Branch.getInstance().application(app, open: url, options: options)
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
          // Handler for Universal Links
        Branch.getInstance().continue(userActivity)
        return true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      // Handler for Push Notifications
      Branch.getInstance().handlePushNotification(userInfo)
    }
}
