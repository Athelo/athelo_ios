//
//  UIColor+Styling.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 30/05/2022.
//

import UIKit

extension UIColor {
    enum AppStyle: String, Equatable {
        case background = "Background"
        case black = "Black"
        case blue1877F2 = "#1877F2"
        case gray = "Gray"
        case green7FC704 = "#7FC704"
        case green8FCC25 = "#8FCC25"
        case green81B821 = "#81B821"
        case greenB5DE71 = "#B5DE71"
        case greenDEEEC3 = "#DEEEC3"
        case inactiveGray = "Inactive Gray"
        case introBlob = "Intro Blob"
        case lightGray = "Light Gray"
        case lightOlivaceous = "Light Olivaceous"
        case olivaceous = "Olivaceous"
        case pickerBackground = "Picker Background"
        case purple623E61 = "#623E61"
        case purple80627F = "#80627F"
        case purple988098 = "#988098"
        case purpleC1B4C0 = "#C1B4C0"
        case redE31A1A = "#E31A1A"
        case redFF0000 = "#FF0000"
        case redFF4D4D = "#FF4D4D"
        case shadow = "Shadow"
        case white = "White"
    }
    
    static func withStyle(_ style: AppStyle) -> UIColor {
        UIColor(named: style.rawValue)!
    }
}


