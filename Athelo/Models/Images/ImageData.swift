//
//  ImageData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 31/05/2022.
//

import Foundation

struct ImageData: Decodable, Equatable, Hashable, Identifiable {
    let id: Int

    let image: URL
    let image50px: URL?
    let image100px: URL?
    let image125px: URL?
    let image250px: URL?
    let image500px: URL?
    let name: String?

    private enum CodingKeys: String, CodingKey {
        case id, image, name
        case image50px = "image_50_50"
        case image100px = "image_100_100"
        case image125px = "image_125_125"
        case image250px = "image_250_250"
        case image500px = "image_500_500"
    }
}
