//
//  CalendarDayCollectionViewCell.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 14/07/2022.
//

import SwiftDate
import UIKit

typealias CalendarDayCellDecorationData = CalendarDayCollectionViewCell.ConfigurationData

final class CalendarDayCollectionViewCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet private weak var labelDay: UILabel!
    @IBOutlet private weak var labelWeekday: UILabel!
    @IBOutlet private weak var stackViewDate: UIStackView!
    @IBOutlet private weak var viewBackground: UIView!
    
    // MARK: - Properties
    private var configurationData: ConfigurationData?
    
    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    // MARK: - Updates
    private func updateAppearance() {
        guard configurationData?.selectable == true else {
            return
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.beginFromCurrentState]) { [weak self] in
            self?.viewBackground.alpha = self?.isSelected == true ? 1.0 : 0.0
        }
        
        UIView.transition(with: labelDay, duration: 0.2, options: [.beginFromCurrentState]) { [weak self] in
            self?.labelWeekday.textColor = .withStyle(self?.isSelected == true ? .purple623E61 : .black)
        }
        
        UIView.transition(with: labelWeekday, duration: 0.2, options: [.beginFromCurrentState]) { [weak self] in
            self?.labelDay.textColor = .withStyle(self?.isSelected == true ? .purple623E61 : .gray)
        }
    }
}

// MARK: - Protocol conformance
// MARK: ConfigurableCell
extension CalendarDayCollectionViewCell: ConfigurableCell {
    struct ConfigurationData {
        let date: Date
        let selectable: Bool
        
        init(date: Date, selectable: Bool = true) {
            self.date = date
            self.selectable = selectable
        }
    }
    
    typealias DataType = ConfigurationData
    
    func configure(_ item: ConfigurationData, indexPath: IndexPath) {
        self.configurationData = item
        
        labelDay.text = "\(item.date.day)"
        labelWeekday.text = "\(item.date.weekdayName(.short))"
        
        if item.selectable {
            viewBackground.alpha = isSelected ? 1.0 : 0.0
            
            labelDay.textColor = .withStyle(isSelected ? .purple623E61 : .black)
            labelWeekday.textColor = .withStyle(isSelected ? .purple623E61 : .gray)
        } else {
            viewBackground.alpha = 0.0
            
            labelDay.textColor = .withStyle(.lightGray)
            labelWeekday.textColor = .withStyle(.lightGray)
        }
    }
}
