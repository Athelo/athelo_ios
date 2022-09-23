import Foundation

public struct ImagesUploadRequest: APIRequest {
    let imageData: Data
    
    public init(imageData: Data) {
        self.imageData = imageData
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}
