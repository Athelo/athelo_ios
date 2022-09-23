//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 30/05/2022.
//

import Foundation

public class APIEnvironment {
    enum EnvironmentError: Error {
        case invalidToken
        case missingApplicationIdentifier
        case missingAppVersion
        case missingChatServicePath
        case missingServicePath
        case missingValue
    }
    
    enum EnvironmentKey: String {
        case applicationIdentifier
        case appVersion
        case chatToken
        case fcmToken
        case servicePath
        case chatServicePath
        case userToken
        
        fileprivate var storeKey: String {
            "networking.api:key.\(rawValue)"
        }
    }
    
    // MARK: - Public API
    public static func applyConfiguration(_ configuration: APIConfiguration) {
        UserDefaults.standard.set(configuration.applicationIdentifier, forKey: EnvironmentKey.applicationIdentifier.storeKey)
        UserDefaults.standard.set(configuration.appVersion, forKey: EnvironmentKey.appVersion.storeKey)
        UserDefaults.standard.set(configuration.chatServicePath, forKey: EnvironmentKey.chatServicePath.storeKey)
        UserDefaults.standard.set(configuration.servicePath, forKey: EnvironmentKey.servicePath.storeKey)
        
        UserDefaults.standard.synchronize()
    }
    
    public static func clearFCMToken() {
        clearToken(for: .fcmToken)
    }
    
    public static func clearUserToken() {
        clearToken(for: .userToken)
    }
    
    public static func hasTokenData() -> Bool {
        storedUserToken() != nil
    }
    
    @discardableResult
    public static func setFCMToken(_ token: String, force: Bool = true) throws -> Bool {
        if !force, let currentToken: String = getToken(for: .fcmToken), !currentToken.isEmpty,
           currentToken == token {
            return false
        }
        
        try setToken(token, for: .fcmToken)
        
        return true
    }
    
    public static func setUserToken(_ token: IdentityTokenData) throws {
        try setToken(token, for: .userToken)
    }
    
    // MARK: - Data access
    static func clearChatToken() {
        clearToken(for: .chatToken)
    }
    
    static func setChatToken(_ token: String) throws {
        try setToken(token, for: .chatToken)
    }
    
    static func storedApplicationIdentifier() throws -> String {
        guard let identifier = UserDefaults.standard.string(forKey: EnvironmentKey.applicationIdentifier.storeKey), !identifier.isEmpty else {
            throw EnvironmentError.missingApplicationIdentifier
        }
        
        return identifier
    }
    
    static func storedAppVersion() throws -> String {
        guard let version = UserDefaults.standard.string(forKey: EnvironmentKey.appVersion.storeKey), !version.isEmpty else {
            throw EnvironmentError.missingAppVersion
        }
        
        return version
    }
    
    static func storedChatServicePath() throws -> String {
        guard let path = UserDefaults.standard.string(forKey: EnvironmentKey.chatServicePath.storeKey), !path.isEmpty else {
            throw EnvironmentError.missingChatServicePath
        }
        
        return path
    }
    
    static func storedChatToken() -> String? {
        getToken(for: .chatToken)
    }
    
    static func storedFCMToken() -> String? {
        getToken(for: .fcmToken)
    }
    
    static func storedServicePath() throws -> String {
        guard let path = UserDefaults.standard.string(forKey: EnvironmentKey.servicePath.storeKey), !path.isEmpty else {
            throw EnvironmentError.missingServicePath
        }
        
        return path
    }
    
    static func storedUserToken() -> IdentityTokenData? {
        getToken(for: .userToken)
    }
        
    // MARK: - Access helpers
    static func clearToken(for key: EnvironmentKey) {
        guard let tokenPath = try? URL.docsPath(for: key.storeKey) else {
            return
        }
        
        try? FileManager.default.removeItem(at: tokenPath)
    }
    
    static func getToken<T: Codable>(for key: EnvironmentKey) -> T? {
        guard let tokenPath = try? URL.docsPath(for: key.storeKey),
              let tokenEncodedData = try? Data(contentsOf: tokenPath),
              let tokenData = Data(base64Encoded: tokenEncodedData) else {
            return nil
        }
        
        if let token = try? JSONDecoder().decode(T.self, from: tokenData) {
            return token
        } else if let token = String(data: tokenData, encoding: .utf8) {
            return token as? T
        }
        
        return nil
    }
    
    static func hasTokenData<T: Codable>(for key: EnvironmentKey, _ type: T.Type) -> Bool {
        guard let _: T = getToken(for: key) else {
            return false
        }
        
        return true
    }
    
    static func setToken<T: Codable>(_ token: T, for key: EnvironmentKey) throws {
        if let token = token as? String {
            guard let tokenData = token.data(using: .utf8)?.base64EncodedData() else {
                throw EnvironmentError.invalidToken
            }
            
            do {
                let tokenPath = try URL.docsPath(for: key.storeKey)
                
                try tokenData.write(to: tokenPath)
            } catch {
                throw EnvironmentError.invalidToken
            }
        } else {
            do {
                let tokenData = try JSONEncoder().encode(token).base64EncodedData()
                let tokenPath = try URL.docsPath(for: key.storeKey)
                
                try tokenData.write(to: tokenPath)
            } catch {
                throw EnvironmentError.invalidToken
            }
        }
    }
}
