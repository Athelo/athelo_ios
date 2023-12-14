//
//  HealthPermissionsData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 21/03/2023.
//

import Foundation

struct HealthPermissionsData: Decodable, Identifiable {
    let id: Int
    
    let feelingsAccess: String
    let healthReports: String
    let symptomsAccess: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case feelingsAccess = "feelings_access"
        case healthReports = "health_reports"
        case symptomsAccess = "symptoms_access"
    }
}
