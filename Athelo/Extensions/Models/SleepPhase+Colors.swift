//
//  SleepPhase+Colors.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/07/2022.
//

import Foundation
import UIKit

extension SleepPhase {
    var color: UIColor {
        switch self {
        case .deep:
            return .withStyle(.greenDEEEC3)
        case .light:
            return .withStyle(.green7FC704)
        case .rem:
            return .withStyle(.lightOlivaceous)
        case .wake:
            return .withStyle(.white)
        }
    }
    
    var labelColorStyle: UIColor.AppStyle {
        switch self {
        case .light, .rem:
            return .white
        case .deep, .wake:
            return .black
        }
    }
}
