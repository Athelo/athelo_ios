//
//  ModelConfigurationData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 06/07/2022.
//

import Foundation

enum ModelConfigurationData<ModelType: Identifiable> {
    case data(ModelType)
    case id(ModelType.ID)
    
    var itemIdentifier: ModelType.ID {
        switch self {
        case .id(let id):
            return id
        case .data(let data):
            return data.id
        }
    }
}

extension ModelConfigurationData: Equatable {
    static func == (lhs: ModelConfigurationData<ModelType>, rhs: ModelConfigurationData<ModelType>) -> Bool {
        switch (lhs, rhs) {
        case (.data(let lhsData), .data(let rhsData)):
            return lhsData.id == rhsData.id
        case (.id(let lhsID), .id(let rhsID)):
            return lhsID == rhsID
        default:
            return false
        }
    }
}

enum ModelConfigurationListData<ModelType: Identifiable> {
    case data([ModelType])
    case id([ModelType.ID])
    
    var itemIdentifiers: [ModelType.ID] {
        switch self {
        case .id(let ids):
            return ids
        case .data(let data):
            return data.map({ $0.id })
        }
    }
}

extension ModelConfigurationListData: Equatable {
    static func == (lhs: ModelConfigurationListData<ModelType>, rhs: ModelConfigurationListData<ModelType>) -> Bool {
        switch (lhs, rhs) {
        case (.data(let lhsData), .data(let rhsData)):
            return Set(lhsData.map({ $0.id })).elementsEqual(Set(rhsData.map({ $0.id })))
        case (.id(let lhsIDs), .id(let rhsIDs)):
            return Set(lhsIDs).elementsEqual(Set(rhsIDs))
        default:
            return false
        }
    }
}
