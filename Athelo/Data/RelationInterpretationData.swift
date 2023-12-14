//
//  RelationInterpretationData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 21/03/2023.
//

import Foundation

struct RelationInterpretationData: Identifiable {
    let relatedPerson: IdentityCommonProfileData
    let relationID: Int
    let relationLabel: String?
    let relationRole: UserRole
    
    var id: Int {
        relationID
    }
    
    init?(relationData: HealthRelationData, relation: UserRole, relationNames: [CaregiverRelationLabelConstant]? = nil) {
        switch relation {
        case .caregiver:
            guard let caregiver = relationData.caregiver else {
                return nil
            }
            
            self.relatedPerson = caregiver
        case .patient:
            guard let patient = relationData.patient else {
                return nil
            }
            
            self.relatedPerson = patient
        }
        
        self.relationID = relationData.id
        self.relationLabel = relationNames?.first(where: { $0.key == relationData.relationLabel })?.name
        self.relationRole = relation
    }
}

extension RelationInterpretationData: ContactData {
    var contactID: Int {
        relatedPerson.contactID
    }
    
    var contactPhoto: ImageData? {
        relatedPerson.contactPhoto
    }
    
    var contactDisplayName: String? {
        relatedPerson.contactDisplayName
    }
    
    var contactRelationName: String? {
        relatedPerson.contactDisplayName
    }
}
