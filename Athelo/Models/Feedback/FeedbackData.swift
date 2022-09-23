//
//  FeedbackData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/06/2022.
//

import Foundation

struct FeedbackData: Decodable, Identifiable {
    let id: Int
    
    let content: String
    let status: Int
    let topic: FeedbackTopicData
}
