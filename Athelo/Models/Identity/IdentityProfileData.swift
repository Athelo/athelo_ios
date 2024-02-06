//
//  IdentityProfileData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 31/05/2022.
//

import Foundation

struct IdentityProfileData: Decodable, Identifiable {
    enum RelationStatus: Int, Decodable {
        case friend = 1
        case invitationReceived = 2
        case rejected = 3
        case invitationSent = 4
        case none = 5
    }
    
    let commonProfileData: IdentityCommonProfileData
    let birthday: Date?
    let email: String?
    let firstName: String?
    let hasFitbitUserProfile: Bool?
    let lastName: String?
    let isFriend: Bool?
    let personTags: [TagData]?
    let phoneNumber: String?
    let relationStatus: RelationStatus?
    let user: IdentityUserData?

    var displayName: String? {
        commonProfileData.displayName
    }
    
    var fullName: String {
        return "\(firstName ?? "") \(lastName ?? "")".trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var id: Int {
        commonProfileData.id
    }
    
    var photo: ImageData? {
        commonProfileData.photo
    }
    
    var profileFriendVisibilityOnly: Bool? {
        commonProfileData.profileFriendVisibilityOnly
    }
    
    var cancerStatus: String?

    private enum CodingKeys: String, CodingKey {
        case email, photo, user
        case birthday = "birthday"
        case firstName = "first_name"
        case hasFitbitUserProfile = "has_fitbit_user_profile"
        case govXStateGUID = "gov_x_state_guid"
        case isFriend = "is_friend"
        case lastName = "last_name"
        case phoneNumber = "phone"
        case personTags = "person_tags"
        case relationStatus = "status"
    }

    init(from decoder: Decoder) throws {
        self.commonProfileData = try IdentityCommonProfileData(from: decoder)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.birthday = try container.decodeDateIfPresent(for: .birthday, format: "yyyy-MM-dd")
        self.email = try container.decodeValueIfPresent(forKey: .email)
        self.firstName = try container.decodeValueIfPresent(forKey: .firstName)
        self.hasFitbitUserProfile = try container.decodeValueIfPresent(forKey: .hasFitbitUserProfile)
        self.isFriend = try container.decodeValueIfPresent(forKey: .isFriend)
        self.lastName = try container.decodeValueIfPresent(forKey: .lastName)
        self.personTags = try container.decodeValueIfPresent(forKey: .personTags)
        self.phoneNumber = try container.decodeValueIfPresent(forKey: .phoneNumber)
        self.relationStatus = try container.decodeValueIfPresent(forKey: .relationStatus)
        self.user = try container.decodeValueIfPresent(forKey: .user)
    }
}

extension IdentityProfileData: ContactData {
    var contactDisplayName: String? {
        displayName
    }
    
    var contactID: Int {
        commonProfileData.id
    }
    
    var contactPhoto: ImageData? {
        photo
    }
    
    var contactRelationName: String? {
        nil
    }
}

extension IdentityProfileData: RendererAvatarSource {
    var rendererAvatarDisplayName: String? {
        displayName
    }
}
