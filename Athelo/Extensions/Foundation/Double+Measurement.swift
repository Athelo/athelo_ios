//
//  Double+Measurement.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 12/07/2022.
//

import Foundation

extension Double {
    /// Creates Measurement instance based on own value.
    ///
    /// - Parameter unit: Unit in which underlying value is going to be treated as.
    func asMeasurementUnit<TargetUnit: Unit>(_ unit: TargetUnit) -> Measurement<TargetUnit> {
        Measurement(value: self, unit: unit)
    }
}
