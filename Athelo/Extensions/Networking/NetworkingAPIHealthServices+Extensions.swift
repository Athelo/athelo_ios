//
//  NetworkingAPIHealthServices+Extensions.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 17/10/2023.
//

import Combine
import Foundation

extension AtheloAPI.Health {
    static func allCaregiversList() -> AnyPublisher<[RelationInterpretationData], Error> {
        Publishers.CombineLatest(
            AtheloAPI.Health.caregiversList()
                .repeating()
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
            AtheloAPI.Health.patientList()
                .repeating()
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
