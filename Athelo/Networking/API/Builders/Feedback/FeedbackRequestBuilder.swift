import Foundation

enum FeedbackRequestBuilder: APIBuilderProtocol {
    case feedback(request: FeedbackRequest)
    case topics

    var headers: [String : String]? {
        switch self {
        case .feedback, .topics:
            return nil
        }
    }

    var method: APIMethod {
        switch self {
        case .feedback:
            return .post
        case .topics:
            return .get
        }
    }

    var parameters: [String : Any]? {
        switch self {
        case .feedback(let request as APIRequest):
            return request.parameters
        case .topics:
            return nil
        }
    }

    var path: String {
        switch self {
        case .feedback:
            return "/applications/feedback/"
        case .topics:
            return "/applications/feedback-topic/"
        }
    }
}
