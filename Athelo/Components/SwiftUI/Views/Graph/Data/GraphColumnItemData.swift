//
//  GraphColumnItemData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/07/2022.
//

import Foundation
import UIKit

struct GraphColumnItemData: Equatable, Hashable, Identifiable {
    let id: Int
    
    let color: UIColor
    let value: CGFloat
    let label: String?
    let labelColorStyle: UIColor.AppStyle
    
    init(id: Int, color: UIColor, value: CGFloat, label: String?, labelColorStyle: UIColor.AppStyle = .black) {
        self.id = id
        self.color = color
        self.value = value
        self.label = label
        self.labelColorStyle = labelColorStyle
    }
}
