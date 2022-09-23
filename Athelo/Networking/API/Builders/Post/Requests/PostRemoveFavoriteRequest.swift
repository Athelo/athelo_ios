//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 06/07/2022.
//

import Foundation

public struct PostRemoveFavoriteRequest: APIRequest {
    let postID: Int
    
    public init(postID: Int) {
        self.postID = postID
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}
