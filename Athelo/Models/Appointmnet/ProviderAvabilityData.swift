//
//  ProviderAvability.swift
//  Athelo
//
//  Created by Devsto on 07/02/24.
//

import Foundation



struct ProviderAvability: Decodable {
    
    
    var responseDates: [[String]] = []
    
//    var times: [String] {
//        get {
//            if responseDates.count > 0 {
//                var tempArray: [String] = []
//                for i in responseDates {
//                    let tempDate = i.toDate(style:.custom("MM/dd/yyyy hh:mm a"))
//                    tempArray.append((tempDate?.toString(.custom("MM/dd/yyyy"))) ?? "")
//                }
//            }
//            return []
//        }
//    }
//    
//    var providerDate: String?{
//        get {
//            if responseDates.count > 0{
//                let tempDate = self.responseDates[0].toDate(style:.custom("MM/dd/yyyy hh:mm a"))
//                return tempDate?.toString(.custom("MM/dd/yyyy"))
//            }
//            return nil
//        }
//    }
//    
    
    private enum CodingKeys: String, CodingKey {
        case responseDates = "results"
      
    }

    init(){ }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.responseDates = try container.decode([[String]].self, forKey: .responseDates)
    }
    
    
    
}
