//
//  ProviderAvability.swift
//  Athelo
//
//  Created by Devsto on 07/02/24.
//

import Foundation

struct ProviderAvability: Decodable {
    
    
    private var responseDates: [[String]] = []
    
    var times: [String] {
        get {
            
//            let formate1 = DateFormatter()
//            let formate2 = DateFormatter()
//            
//            formate1.locale = Locale(identifier: "\(Locale.current.identifier)_POSIX")
//            formate2.locale = Locale(identifier: "\(Locale.current.identifier)_POSIX")
//            formate1.dateFormat = "MM/dd/yyyy hh:mm a"
//            formate2.dateFormat = "hh:mm a"
            if responseDates.count > 0 {
                var tempArray: [String] = []
                for i in responseDates[0] {
//                    guard let date1 = formate1.date(from: i) else {
//                        print("Date Formate invalid in time slot")
//                        break
//                    }
//                    tempArray.append(formate2.string(from: date1))
                    tempArray.append(i.changeDateStringTo(Base: .MM_dd_yyyy_hh_mm_a, Changeto: .hh_mm_a) ?? "Invalid DFormmate")
                    
                }
                return tempArray
            }
            return []
        }
    }
    
    var providerDate: String?{
        get {
            if responseDates.count > 0{
                let tempDate = self.responseDates[0][0].toDate(style:.custom("MM/dd/yyyy hh:mm a"))
                return tempDate?.toString(.custom("MM/dd/yyyy"))
            }
            return nil
        }
    }
    
    
    private enum CodingKeys: String, CodingKey {
        case responseDates = "results"
      
    }

    init(){ }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.responseDates = try container.decode([[String]].self, forKey: .responseDates)
    }
    
}
