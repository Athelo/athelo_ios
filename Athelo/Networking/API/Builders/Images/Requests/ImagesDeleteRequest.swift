import Foundation

public struct ImagesDeleteRequest: APIRequest {
    let imageID: Int
    
    public init(imageID: Int) {
        self.imageID = imageID
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

