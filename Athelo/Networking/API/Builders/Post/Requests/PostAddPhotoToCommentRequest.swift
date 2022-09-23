import Foundation

public struct PostAddPhotoToCommentRequest: APIRequest {
    let commentID: Int
    let photoID: Int
    
    public init(commentID: Int, photoID: Int) {
        self.commentID = commentID
        self.photoID = photoID
    }
    
    public var parameters: [String : Any]? {
        ["photo_id": photoID]
    }
}
