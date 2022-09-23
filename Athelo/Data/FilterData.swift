//
//  FilterData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 07/07/2022.
//

import Foundation

protocol Filterable {
    var filterOptionName: String { get }
    var filterOptionID: Int { get }
}

struct FilterData {
    let filterable: Filterable
    let isSelected: Bool
}
