//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 28/06/2022.
//

import Foundation

public struct NetworkingImageData: Decodable, Hashable, Identifiable {
    public let id: Int
    
    public let image: URL
    public let image50px: URL?
    public let image100px: URL?
    public let image125px: URL?
    public let image250px: URL?
    public let image500px: URL?
    public let name: String?

    private enum CodingKeys: String, CodingKey {
        case id, image, name
        case image50px = "image_50_50"
        case image100px = "image_100_100"
        case image125px = "image_125_125"
        case image250px = "image_250_250"
        case image500px = "image_500_500"
    }
}
