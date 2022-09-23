//
//  GraphLegendItemData+Size.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 11/08/2022.
//

import Foundation
import UIKit

extension Array where Element == GraphLegendItemData {
    var maxContentWidth: Double {
        map({ NSString(string: $0.name).boundingRect(with: .init(width: .greatestFiniteMagnitude, height: 1.0), options: [.usesLineFragmentOrigin], attributes: [.font: UIFont.withStyle(.legend)], context: nil).width }).max() ?? 0.0
    }
}
