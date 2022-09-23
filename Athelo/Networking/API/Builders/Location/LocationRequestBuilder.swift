import Foundation

enum LocationRequestBuilder: APIBuilderProtocol {
    case categoriesList
    case details(request: LocationDetailsRequest)
    case list(request: LocationListRequest)
    
    var headers: [String : String]? {
        switch self {
        case .categoriesList, .details, .list:
            return nil
        }
    }
    
    var method: APIMethod {
        switch self {
        case .categoriesList, .details, .list:
            return .get
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .categoriesList:
            return nil
        case .details(let request as APIRequest),
                .list(let request as APIRequest):
            return request.parameters
        }
    }
    
    var path: String {
        switch self {
        case .categoriesList:
            return "/locations/location-categories/"
        case .details(let request):
            return "/locations/locations/\(request.id)"
        case .list(let request):
            var path = "/locations/locations/?"
            
            if let categoryIDs = request.filterData?.categories?.map({ "\($0)" }), !categoryIDs.isEmpty {
                path += "&category__id__in=\(categoryIDs.map({ "\($0)" }).joined(separator: ","))"
            }
            
            if let query = request.filterData?.query?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), !query.isEmpty {
                path += "&name__icontains=\(query)"
            }
            
            if request.filterData?.nearbyOnly == true,
               let coordinate = request.filterData?.nearbyCoordinate {
                let appendedPath = "&within_radius=\(coordinate.latitude),\(coordinate.longitude)"
                path += appendedPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? appendedPath.replacingOccurrences(of: " ", with: "%20")
            }
            
            return path
        }
    }
}
