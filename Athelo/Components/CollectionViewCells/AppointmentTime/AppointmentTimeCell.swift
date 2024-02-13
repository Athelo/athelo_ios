//
//  AppointmentTimeCell.swift
//  Athelo
//
//  Created by Devsto on 02/02/24.
//

import UIKit

enum AppointmentTimeCellState{
    case selected
    case normal
    
    var viewColor: UIColor {
        switch self {
        case .selected:
            return #colorLiteral(red: 0.4078431373, green: 0.5843137255, blue: 0.1058823529, alpha: 1)
        case .normal:
            return .white
        }
    }
    
    var textColor: UIColor {
        switch self {
            
        case .selected:
            return .white
        case .normal:
            return #colorLiteral(red: 0.3843137255, green: 0.2431372549, blue: 0.3803921569, alpha: 1)
        }
    }
    
    var borderColor: UIColor {
        switch self {
        case .selected:
            return  #colorLiteral(red: 0.4078431373, green: 0.5843137255, blue: 0.1058823529, alpha: 1)
        case .normal:
            return  #colorLiteral(red: 0.3843137255, green: 0.2431372549, blue: 0.3803921569, alpha: 1)
        }
    }
}

class AppointmentTimeCell: UICollectionViewCell {
    
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var timeLbl: UILabel!

    
}

extension AppointmentTimeCell: ConfigurableCell{
   
    typealias DataType = AppointmentTimeCellState
    
    func configure(_ item: AppointmentTimeCellState, indexPath: IndexPath) {
        timeView.backgroundColor = item.viewColor
        timeView.layer.borderColor = item.borderColor.cgColor
        timeView.layer.borderWidth = 1
        timeLbl.textColor = item.textColor
        
    }
    
}

