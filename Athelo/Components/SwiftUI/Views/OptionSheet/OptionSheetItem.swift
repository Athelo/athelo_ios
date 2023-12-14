//
//  OptionSheetItem.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/03/2023.
//

import UIKit

struct OptionSheetItem: Identifiable {
    let id: UUID = UUID()
    
    let name: String
    let icon: UIImage
    let destructive: Bool
    let action: () -> Void
    
    init(name: String, icon: UIImage, destructive: Bool = false, action: @escaping () -> Void) {
        self.name = name
        self.icon = icon
        self.destructive = destructive
        self.action = action
    }
    
    var actionStyle: UIColor.AppStyle {
        destructive ? .redE31A1A : .purple623E61
    }
    
    var actionColor: UIColor {
        .withStyle(actionStyle)
    }
}
