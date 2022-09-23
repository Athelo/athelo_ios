//
//  Double+ChartLegend.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 09/08/2022.
//

import Foundation

extension Double {
    func chartLegendInterval(looseningFirstIntervalGap: Bool = false) -> Double {
        switch self {
        case _ where self <= (looseningFirstIntervalGap ? 20 : 10):
            return 1
        case _ where self <= 20:
            return 2
        case _ where self <= 50:
            return 5
        case _ where self <= 100:
            return 10
        case _ where self <= 150:
            return 30
        case _ where self <= 500:
            return 50
        case _ where self <= 1000:
            return 100
        case _ where self <= 5000:
            return 500
        case _ where self <= 10000:
            return 1000
        case _ where self <= 25000:
            return 5000
        case _ where self <= 100000:
            return 10000
        default:
            break
        }
        
        return self / 10
    }
}
