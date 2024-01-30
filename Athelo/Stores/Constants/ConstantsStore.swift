//
//  ConstantsStore.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 06/06/2022.
//

import Combine
import Foundation

final class ConstantsStore {
    // MARK: - Constants
    fileprivate typealias DataTypeKey = NSString
    
    enum DataType: String {
        case applicationData
        case constants
        case feedbackTopics
        case newsTopics
        
        fileprivate var typeKey: DataTypeKey {
            rawValue as DataTypeKey
        }
    }
    
    // MARK: - Properties
    static let instance = ConstantsStore()
    
    private let cache = NSCache<DataTypeKey, ConstantObjectWrapper>()
    private var deviceConfigData: DeviceConfigData?
    
    // MARK: - Subscripts
    private subscript(_ key: DataType) -> Any? {
        set {
            if let value = newValue {
                cache.setObject(ConstantObjectWrapper(wrapped: value), forKey: key.typeKey)
            } else {
                cache.removeObject(forKey: key.typeKey)
            }
        }
        get {
            cache.object(forKey: key.typeKey)?.wrapped
        }
    }
    
    // MARK: - Initialization
    private init() {
        /* ... */
    }
    
    static func applicationData() -> ApplicationData? {
        instance[.applicationData] as? ApplicationData
    }
    
    static func applicationDataPublisher() -> AnyPublisher<ApplicationData, Error> {
        if let applicationData = self.applicationData() {
            return Just(applicationData)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return Publishers.NetworkingPublishers.ListRepeatingPublisher(initialRequest: Deferred { AtheloAPI.Applications.applications() as AnyPublisher<ListResponseData<ApplicationData>, APIError> })
            .mapError({ $0 as Error })
            .tryMap({ value -> ApplicationData in
                guard let application = value.first else {
                    throw CommonError.missingContent
                }
                
                return application
            })
            .handleEvents(receiveOutput: {
                instance[.applicationData] = $0
            })
            .eraseToAnyPublisher()
    }
    
    static func constants() -> ServiceConstants? {
        instance[.constants] as? ServiceConstants
    }
    
    static func constantsPublisher() -> AnyPublisher<ServiceConstants, Error> {
        if let constants = self.constants() {
            return Just(constants)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return (AtheloAPI.Constants.constants() as AnyPublisher<ServiceConstants, APIError>)
            .mapError({ $0 as Error })
            .handleEvents(receiveOutput: {
                instance[.constants] = $0
            })
            .eraseToAnyPublisher()
    }
    
    static func deviceConfigData() -> DeviceConfigData? {
        instance.deviceConfigData
    }
    
    static func deviceConfigDataPublisher() -> AnyPublisher<DeviceConfigData, Error> {
        if let deviceConfigData = instance.deviceConfigData {
            return Just(deviceConfigData)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return (AtheloAPI.DeviceConfig.deviceConfig() as AnyPublisher<DeviceConfigData, APIError>)
            .mapError({ $0 as Error })
            .handleEvents(receiveOutput: {
                instance.deviceConfigData = $0
            })
            .eraseToAnyPublisher()
    }
    
    static func feedbackTopics() -> [FeedbackTopicData]? {
        instance[.feedbackTopics] as? [FeedbackTopicData]
    }
    
    static func feedbackTopicsPublisher() -> AnyPublisher<[FeedbackTopicData], Error> {
        if let feedbackTopics = self.feedbackTopics() {
            return Just(feedbackTopics)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let initialRequest = Deferred { AtheloAPI.Feedback.topics() as AnyPublisher<ListResponseData<FeedbackTopicData>, APIError> }
        return Publishers.NetworkingPublishers.ListRepeatingPublisher(initialRequest: initialRequest)
            .mapError({ $0 as Error })
            .handleEvents(receiveOutput: {
                instance[.feedbackTopics] = $0
            })
            .eraseToAnyPublisher()
    }
    
    static func describesYouPublisher() -> AnyPublisher<[DescribesYou], Error> {
            return Just(DescribesYou.allCases)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
    }
    
    static func newsTopics() -> [NewsTopicData]? {
        instance[.newsTopics] as? [NewsTopicData]
    }
    
    static func newsTopicsPublisher() -> AnyPublisher<[NewsTopicData], Error> {
        if let newsTopics = self.newsTopics() {
            return Just(newsTopics)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let initialRequest = Deferred { AtheloAPI.Posts.categories() as AnyPublisher<ListResponseData<NewsTopicData>, APIError> }
        return Publishers.NetworkingPublishers.ListRepeatingPublisher(initialRequest: initialRequest)
            .mapError({ $0 as Error })
            .handleEvents(receiveOutput: {
                instance[.newsTopics] = $0
            })
            .eraseToAnyPublisher()
    }
}

// MARK - Helper extensions
private extension ConstantsStore {
    final class ConstantObjectWrapper: NSObject {
        let wrapped: Any
        
        init(wrapped: Any) {
            self.wrapped = wrapped
        }
    }
}
