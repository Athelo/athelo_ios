import Foundation

public protocol CoordinateData: Decodable {
    var latitude: Double { get }
    var longitude: Double { get }
}

public struct LocationListRequest: APIRequest {
    public struct FilterData {
        let categories: [Int]?
        let nearbyOnly: Bool
        let nearbyCoordinate: CoordinateData?
        let query: String?
        
        init(categories: [Int]? = nil, nearbyOnly: Bool = false, nearbyCoordinate: CoordinateData? = nil, query: String? = nil) {
            self.categories = categories
            self.nearbyOnly = nearbyOnly
            self.nearbyCoordinate = nearbyCoordinate
            self.query = query
        }
        
        var isEmpty: Bool {
            !(categories?.isEmpty == false) && !nearbyOnly && query == nil
        }
    }
    
    let filterData: FilterData?
    
    public init(filterData: FilterData? = nil) {
        self.filterData = filterData
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}
