//
//  SelectedDateModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 20/07/2022.
//

import Foundation

final class SelectedDateModel: ObservableObject {
    @Published var date: Date
    
    init(date: Date) {
        self.date = date
    }
}
