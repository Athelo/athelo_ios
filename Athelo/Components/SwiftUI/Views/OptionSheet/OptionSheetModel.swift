//
//  OptionSheetModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/03/2023.
//

import Foundation
import SwiftUI

final class OptionSheetModel: ObservableObject {
    @Published private(set) var visible: Bool = false
    
    let actions: [OptionSheetItem]
    
    init(actions: [OptionSheetItem]) {
        self.actions = actions
    }
    
    func toggleVisibility() {
        withAnimation(.spring().speed(1.25)) {
            visible.toggle()
        }
    }
}
