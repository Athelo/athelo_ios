import Foundation

public struct PostCommentDetailsRequest: APIRequest {
    let commentID: Int
    
    public init(commentID: Int) {
        self.commentID = commentID
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}
