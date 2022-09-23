//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 01/07/2022.
//

import Foundation

public struct PostAddFavoriteRequest: APIRequest {
    let postID: Int
    
    public init(postID: Int) {
        self.postID = postID
    }
    
    public var parameters: [String : Any]? {
        ["post_id": postID]
    }
}
