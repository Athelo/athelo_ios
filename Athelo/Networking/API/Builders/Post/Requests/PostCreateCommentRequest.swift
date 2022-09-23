import Foundation

public struct PostCreateCommentRequest: APIRequest {
    let text: String
    let postID: Int
    
    public init(text: String, postID: Int) {
        self.text = text
        self.postID = postID
    }
    
    public var parameters: [String : Any]? {
        ["content": text,
         "post_id": postID]
    }
}
