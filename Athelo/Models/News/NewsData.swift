//
//  NewsDAta.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 04/07/2022.
//

import Foundation

struct NewsData: Decodable, Equatable, Identifiable, Hashable {
    let id: Int
    
    let content: String?
    let contentURL: URL?
    let createdAt: Date
    let isFavourite: Bool
    let title: String?
    let photo: ImageData?
    let updatedAt: Date?
    
    private enum CodingKeys: String, CodingKey {
        case id, content, title, photo
        case contentURL = "content_url"
        case createdAt = "created_at"
        case isFavourite = "is_favourite"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decodeValue(forKey: .id)
        
        self.content = try container.decodeValueIfPresent(forKey: .content)
        self.contentURL = try container.decodeValueIfPresent(forKey: .contentURL)
        self.createdAt = try container.decodeISODate(for: .createdAt)
        self.isFavourite = try container.decodeValue(forKey: .isFavourite)
        self.title = try container.decodeValueIfPresent(forKey: .title)
        self.photo = try container.decodeValueIfPresent(forKey: .photo)
        self.updatedAt = try container.decodeISODateIfPresent(for: .updatedAt)
    }
}

extension NewsData: ArticleCellDecorationData {
    var articleCellBody: String? {
        content
    }
    
    var articleCellPhoto: LoadableImageData? {
        guard let photo = photo else {
            return nil
        }
        
        return .url(photo.image250px ?? photo.image)
    }
    
    var articleCellTitle: String? {
        title
    }
}
