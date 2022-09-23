import Foundation

public struct EventsListRequest: APIRequest {
    public struct FilterData {
        let tags: [Int]
        let categories: [Int]
        let coordinate: CoordinateData?
        
        init(tags: [Int], categories: [Int], coordinate: CoordinateData? = nil) {
            self.tags = tags
            self.categories = categories
            self.coordinate = coordinate
        }
        
        var isEmpty: Bool {
            tags.isEmpty && categories.isEmpty && coordinate == nil
        }
    }
    
    let pageSize: Int?
    let start: Date?
    let end: Date?
    let filters: FilterData?

    public init(pageSize: Int? = nil, startDate: Date? = nil, endDate: Date? = nil, filters: FilterData? = nil) {
        self.pageSize = pageSize
        self.filters = filters
        self.start = startDate
        self.end = endDate
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}
