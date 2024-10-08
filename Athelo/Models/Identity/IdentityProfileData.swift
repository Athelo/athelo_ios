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
    
    let id: Int

    let dateOfBirth: Date?
    let displayName: String?
    let email: String?
    let firstName: String?
    let hasFitbitUserProfile: Bool?
    let lastName: String?
    let isFriend: Bool?
    let personTags: [TagData]?
    let phoneNumber: String?
    let photo: ImageData?
    let profileFriendVisibilityOnly: Bool?
    let relationStatus: RelationStatus?
    let user: IdentityUserData?
    let userType: Int?

    var fullName: String {
        return "\(firstName ?? "") \(lastName ?? "")".trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private enum CodingKeys: String, CodingKey {
        case id, email, photo, user
        case dateOfBirth = "date_of_birth"
        case displayName = "display_name"
        case firstName = "first_name"
        case hasFitbitUserProfile = "has_fitbit_user_profile"
        case govXStateGUID = "gov_x_state_guid"
        case isFriend = "is_friend"
        case lastName = "last_name"
        case phoneNumber = "phone_number"
        case personTags = "person_tags"
        case profileFriendVisibilityOnly = "profile_friend_visibility_only"
        case relationStatus = "status"
        case userType = "athelo_user_type"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.dateOfBirth = try container.decodeDateIfPresent(for: .dateOfBirth, format: "yyyy-MM-dd")
        self.displayName = try container.decodeValueIfPresent(forKey: .displayName)
        self.email = try container.decodeValueIfPresent(forKey: .email)
        self.firstName = try container.decodeValueIfPresent(forKey: .firstName)
        self.hasFitbitUserProfile = try container.decodeValueIfPresent(forKey: .hasFitbitUserProfile)
        self.id = try container.decodeValue(forKey: .id)
        self.isFriend = try container.decodeValueIfPresent(forKey: .isFriend)
        self.lastName = try container.decodeValueIfPresent(forKey: .lastName)
        self.personTags = try container.decodeValueIfPresent(forKey: .personTags)
        self.phoneNumber = try container.decodeValueIfPresent(forKey: .phoneNumber)
        self.photo = try container.decodeValueIfPresent(forKey: .photo)
        self.profileFriendVisibilityOnly = try container.decodeValueIfPresent(forKey: .profileFriendVisibilityOnly)
        self.relationStatus = try container.decodeValueIfPresent(forKey: .relationStatus)
        self.user = try container.decodeValueIfPresent(forKey: .user)
        self.userType = try? container.decodeValue(forKey: .userType)
    }
}

extension IdentityProfileData: RendererAvatarSource {
    var rendererAvatarDisplayName: String? {
        displayName
    }
}
