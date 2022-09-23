import Foundation

public struct DealListRequest: APIRequest {
    public struct FilterData {
        let topDeals: Bool?
        let nearbyOnly: Bool
        let nearbyCoordinate: CoordinateData?
        let query: String?
        
        init(topDeals: Bool? = nil, nearbyOnly: Bool = false, nearbyCoordinate: CoordinateData? = nil, query: String? = nil) {
            self.topDeals = topDeals
            self.nearbyOnly = nearbyOnly
            self.nearbyCoordinate = nearbyCoordinate
            self.query = query
        }
        
        var isEmpty: Bool {
            topDeals == nil && !nearbyOnly && query == nil
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
