import Foundation

enum ImagesRequestBuilder: APIBuilderProtocol {
    case upload(request: ImagesUploadRequest)
    case delete(request: ImagesDeleteRequest)

    var contentType: APIContentType {
        switch self {
        case .delete:
            return .json
        case .upload(let request):
            return .multipartJPEG(request.imageData)
        }
    }

    var headers: [String : String]? {
        switch self {
        case .delete, .upload:
            return nil
        }
    }

    var method: APIMethod {
        switch self {
        case .delete:
            return .delete
        case .upload:
            return .post
        }
    }

    var parameters: [String : Any]? {
        switch self {
        case .delete(let request as APIRequest):
            return request.parameters
        case .upload:
            return nil
        }
    }

    var path: String {
        switch self {
        case .delete(let request):
            return "/common/image/\(request.imageID)/"
        case .upload:
            return "/common/image/"
        }
    }
}
