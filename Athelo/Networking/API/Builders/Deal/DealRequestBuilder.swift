import Foundation

enum DealRequestBuilder: APIBuilderProtocol {
    case details(request: DealDetailsRequest)
    case list(request: DealListRequest)
    
    var headers: [String : String]? {
        switch self {
        case .details, .list:
            return nil
        }
    }
    
    var method: APIMethod {
        switch self {
        case .details, .list:
            return .get
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .details(let request as APIRequest),
                .list(let request as APIRequest):
            return request.parameters
        }
    }
    
    var path: String {
        switch self {
        case .details(let request):
            return "/deals/deals/\(request.id)"
        case .list(let request):
            var path = "/deals/deals/?"
            
            if let topDeals = request.filterData?.topDeals {
                path += "&top_deal=\(topDeals)"
            }
            
            if let query = request.filterData?.query?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), !query.isEmpty {
                path += "&name__icontains=\(query)"
            }
            
            if request.filterData?.nearbyOnly == true,
               let coordinate = request.filterData?.nearbyCoordinate {
                let appendedPath = "&locations__within_radius=\(coordinate.latitude),\(coordinate.longitude)"
                path += appendedPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? appendedPath.replacingOccurrences(of: " ", with: "%20")
            }
            
            return path
        }
    }
}
