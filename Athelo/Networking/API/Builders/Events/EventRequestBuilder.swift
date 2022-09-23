import CoreLocation
import Foundation

enum EventsRequestBuilder: APIBuilderProtocol {
    case categories
    case details(request: EventDetailsRequest)
    case list(request: EventsListRequest)

    var headers: [String : String]? {
        switch self {
        case .categories, .details, .list:
            return nil
        }
    }

    var method: APIMethod {
        switch self {
        case .categories, .details, .list:
            return .get
        }
    }

    var parameters: [String : Any]? {
        switch self {
        case .categories:
            return nil
        case .details(let request as APIRequest),
             .list(let request as APIRequest):
            return request.parameters
        }
    }

    var path: String {
        switch self {
        case .categories:
            return "/events/event-categories/"
        case .details(let request):
            return "/events/events/\(request.id)/"
        case .list(let request):
            var path = "/events/events/?"

            if let pageSize = request.pageSize, pageSize > 0 {
                path += "&page_size=\(pageSize)"
            }
            
            let dateFormatter = ISO8601DateFormatter()
            if let startDate = request.start {
                path += "&date__gte=\(dateFormatter.string(from: startDate))"
            }
            if let endDate = request.end {
                path += "&date__lte=\(dateFormatter.string(from: endDate))"
            }
            
            if let filters = request.filters {
                if !filters.tags.isEmpty {
                    path += "&tags__contains=\(filters.tags.map({ "\($0)" }).joined(separator: ","))"
                }
                if !filters.categories.isEmpty {
                    path += "&type__id__in=\(filters.categories.map({ "\($0)" }).joined(separator: ","))"
                }
                if let coordinate = filters.coordinate {
                    let appendedPath = "&location__within_radius=\(coordinate.latitude), \(coordinate.longitude)"
                    path += appendedPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? appendedPath.replacingOccurrences(of: " ", with: "%20")
                }
            }

            return path
        }
    }
}


// MARK: - EventsListRequestProtocol
//var startDate: String? {
//    guard let startDate = start else {
//        return nil
//    }
//    return ISO8601DateFormatter.current.string(from: startDate)
//}
//var endDate: String? {
//    guard let endDate = end else {
//        return nil
//    }
//    return ISO8601DateFormatter.current.string(from: endDate)
//}
