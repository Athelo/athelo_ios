//
//  SymptomData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 18/07/2022.
//

import Foundation

struct SymptomData: Decodable, Identifiable {
    let id: Int
    
    let name: String
    let description: String?
    let icon: ImageData?
    let isPublic: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case id, name, description, icon
        
        case isPublic = "is_public"
    }
}

extension SymptomData: ListInputCellItemData {
    var listInputItemID: Int {
        id
    }
    
    var listInputItemName: String {
        name
    }
}

extension SymptomData: ListTileDataProtocol {
    var listTileTitle: String {
        name
    }
    
    var listTileImage: LoadableImageData? {
        guard let icon = icon?.fittingImageURL(forSizeInPixels: 24.0) else {
            return nil
        }
        
        return .url(icon)
    }
}
