//
//  ServiceConstantsData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 06/06/2022.
//

import Foundation

// MARK: - Base data types
protocol ServiceConstantIntIdentifiableProtocol: Codable {
    var id: Int { get }
    var name: String { get }

    init(id: Int, name: String)
}

extension ServiceConstantIntIdentifiableProtocol {
    init(id: Int, name: String) {
        self.init(id: id, name: name)
    }
}

protocol ServiceConstantStringIdentifiableProtocol: Codable {
    var key: String { get }
    var name: String { get }

    init(key: String, name: String)
}

extension ServiceConstantStringIdentifiableProtocol {
    init(key: String, name: String) {
        self.init(key: key, name: name)
    }
}

struct ServiceConstantValue: Codable {
    let intValue: Int?
    let stringValue: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intValue = try? container.decode(Int.self) {
            self.intValue = intValue
            self.stringValue = nil
        } else if let stringValue = try? container.decode(String.self) {
            self.intValue = nil
            self.stringValue = stringValue
        } else {
            self.intValue = nil
            self.stringValue = nil
            
        }
    }
}

private extension Array where Element == [ServiceConstantValue] {
    func toIntIdentifiableValues<T: ServiceConstantIntIdentifiableProtocol>() -> [T] {
        compactMap({
            guard let id = $0[safe: 0]?.intValue, let name = $0[safe: 1]?.stringValue else {
                return nil
            }
            return T(id: id, name: name)
        })
    }

    func toStringIdentifiableValues<T: ServiceConstantStringIdentifiableProtocol>() -> [T] {
        compactMap({
            guard let key = $0[safe: 0]?.stringValue, let name = $0[safe: 1]?.stringValue else {
                return nil
            }
            return T(key: key, name: name)
        })
    }
}

// MARK: - Service data types definition
struct CaregiverRelationLabelConstant: ServiceConstantStringIdentifiableProtocol {
    let key: String
    let name: String
}

struct FeedbackCategoryServiceConstant: ServiceConstantIntIdentifiableProtocol {
    let id: Int
    let name: String
}

struct FriendRequestStatusServiceConstant: ServiceConstantIntIdentifiableProtocol {
    let id: Int
    let name: String
}

struct ReportedChatMessageTypeServiceConstant: ServiceConstantIntIdentifiableProtocol, Hashable {
    let id: Int
    let name: String

    init(id: Int, name: String) {
        self.id = id
        self.name = name.untanglingSnakeUppercase()
    }
}

struct ThirdPartyAccessTokenSourceServiceConstant: ServiceConstantStringIdentifiableProtocol {
    let key: String
    let name: String
}

struct UserProfileStatusServiceConstant: ServiceConstantIntIdentifiableProtocol {
    let id: Int
    let name: String
}

struct ServiceConstants: Codable {
    let caregiverRelationLabels: [CaregiverRelationLabelConstant]
    let feedbackCategories: [FeedbackCategoryServiceConstant]
    let friendRequestStatusTypes: [FriendRequestStatusServiceConstant]
    let reportedChatMessageTypes: [ReportedChatMessageTypeServiceConstant]
    let thirdPartyAccessTokenSources: [ThirdPartyAccessTokenSourceServiceConstant]
    let userProfileStatusTypes: [UserProfileStatusServiceConstant]

    private enum CodingKeys: String, CodingKey {
        case caregiverRelationLabels = "caregiver_relation_label"
        case feedbackCategories = "feedback_category"
        case friendRequestStatusTypes = "friend_request_status"
        case reportedChatMessageTypes = "reported_chat_message_type"
        case thirdPartyAccessTokenSources = "third_party_access_token_source"
        case userProfileStatusTypes = "userprofile_status"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.caregiverRelationLabels = try container.decodeIdentifiableValues(forKey: .caregiverRelationLabels)
        self.feedbackCategories = try container.decodeIdentifiableValues(forKey: .feedbackCategories)
        self.friendRequestStatusTypes = try container.decodeIdentifiableValues(forKey: .friendRequestStatusTypes)
        self.reportedChatMessageTypes = try container.decodeIdentifiableValues(forKey: .reportedChatMessageTypes)
        self.thirdPartyAccessTokenSources = try container.decodeIdentifiableValues(forKey: .thirdPartyAccessTokenSources)
        self.userProfileStatusTypes = try container.decodeIdentifiableValues(forKey: .userProfileStatusTypes)
    }
}

// MARK: Helper extensions
private extension KeyedDecodingContainer {
    func decodeIdentifiableValues<T: ServiceConstantIntIdentifiableProtocol>(forKey key: Self.Key) throws -> [T] {
        try decode([[ServiceConstantValue]].self, forKey: key).toIntIdentifiableValues()
    }

    func decodeIdentifiableValues<T: ServiceConstantStringIdentifiableProtocol>(forKey key: Self.Key) throws -> [T] {
        try decode([[ServiceConstantValue]].self, forKey: key).toStringIdentifiableValues()
    }
}

private extension String {
    func untanglingSnakeUppercase() -> String {
        components(separatedBy: "_").map({ $0.capitalized }).joined(separator: " ")
    }
}

extension CaregiverRelationLabelConstant: ListInputCellItemData {
    // TODO: This doesn't look great - think of a way to either unbind ID type or generate static UI based on whatever.
    var listInputItemID: Int {
        key.hashValue
    }
    
    var listInputItemName: String {
        name
    }
}

extension FeedbackCategoryServiceConstant: ListInputCellItemData {
    var listInputItemID: Int {
        id
    }
    
    var listInputItemName: String {
        name
    }
}
