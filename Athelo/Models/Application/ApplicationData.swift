//
//  ApplicationData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 22/07/2022.
//

import Foundation

struct ApplicationData: Decodable {
    
    let aboutUs: String?
    let privacy: String?
    let termsOfUse: String?
    
    private enum CodingKeys: String, CodingKey {
        case privacy
        case aboutUs = "about_us"
        case termsOfUse = "terms_of_use"
    }
}
