import Foundation

public struct PostCreatePostRequest: APIRequest {
    let categoryID: Int
    let photoID: Int?
    let title: String
    let text: String

    public init(categoryID: Int, title: String, text: String, photoID: Int? = nil) {
        self.categoryID = categoryID
        self.photoID = photoID
        self.title = title
        self.text = text
    }
    
    public var parameters: [String : Any]? {
        var parameters: [String: Any] = [:]

        parameters["category_ids"] = [categoryID]
        parameters["content"] = text
        parameters["title"] = title
        parameters["photo_id"] = photoID

        return parameters
    }
}
