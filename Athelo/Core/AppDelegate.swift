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
//        NotificationUtility.registerForNotifications(in: application)
        
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
        // Values will be hardcoded for now - later on, configurations for STG and PROD envs should be created.
        let configuration = APIConfiguration(
            applicationIdentifier: "ATHELO-QA",
            chatIdentifier: "Athelo",
            appVersion: Bundle.main.appBuild,
            servicePath: "https://i2a-social-api-qa.i2asolutions.com/api/v1",
            chatServicePath: "https://chat-server-stg.i2asolutions.com/socket/"
        )
        
        APIEnvironment.applyConfiguration(configuration)
    }
}

