//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 30/05/2022.
//

import Foundation

public struct APIConfiguration {
    let applicationIdentifier: String
    let chatIdentifier: String
    let appVersion: String
    let servicePath: String
    let chatServicePath: String
    
    public init(applicationIdentifier: String, chatIdentifier: String, appVersion: String, servicePath: String, chatServicePath: String) {
        self.applicationIdentifier = applicationIdentifier
        self.chatIdentifier = chatIdentifier
        self.appVersion = appVersion
        self.servicePath = servicePath
        self.chatServicePath = chatServicePath
    }
}
