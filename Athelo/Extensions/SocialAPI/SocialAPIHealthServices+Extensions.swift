//
//  SocialAPIHealthServices+Extensions.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 21/03/2023.
//

import Combine
import Foundation
import SocialAPI

extension SocialAPI.Health {
    static func allCaregiversList() -> AnyPublisher<[RelationInterpretationData], Error> {
        Publishers.CombineLatest(
            Publishers.SocialPublishers.ListRepeatingPublisher(initialRequest: Deferred { SocialAPI.Health.caregiversList() as AnyPublisher<ListResponseData<HealthRelationData>, SocialAPIError> })
                .mapError({ $0 as Error }),
            ConstantsStore.constantsPublisher()
                .map(\.caregiverRelationLabels)
        )
        .map({ (relationData, relationNames) in
            relationData.compactMap({ RelationInterpretationData(relationData: $0, relation: .caregiver, relationNames: relationNames) })
        })
        .eraseToAnyPublisher()
    }
    
    static func allPatientsList() -> AnyPublisher<[RelationInterpretationData], Error> {
        Publishers.CombineLatest(
            Publishers.SocialPublishers.ListRepeatingPublisher(initialRequest: Deferred { SocialAPI.Health.patientList() as AnyPublisher<ListResponseData<HealthRelationData>, SocialAPIError> })
                .mapError({ $0 as Error }),
            ConstantsStore.constantsPublisher()
                .map(\.caregiverRelationLabels)
        )
        .map({ (relationData, relationNames) in
            relationData.compactMap({ RelationInterpretationData(relationData: $0, relation: .patient, relationNames: relationNames) })
        })
        .eraseToAnyPublisher()
    }
}
