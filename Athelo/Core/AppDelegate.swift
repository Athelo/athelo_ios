//
//  AppDelegate.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 30/05/2022.
//

import FirebaseCore
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    // Override point for customization after application launch.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
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

