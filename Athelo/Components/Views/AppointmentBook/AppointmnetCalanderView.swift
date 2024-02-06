//
//  AppointmnetCalanderView.swift
//  Athelo
//
//  Created by Devsto on 02/02/24.
//

import Foundation
import UIKit

final class AppointmnetCalanderView: UIView{
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timeSlotView: UIView!
    @IBOutlet weak var dateBackgroundView: UIView!
    @IBOutlet weak var selectedDateLbl: UILabel!
    @IBOutlet weak var selectedDateView: UIView!
    @IBOutlet weak var scheduleBtn: StyledButton!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    // MARK: - Properties
    var reloadCell: ((String?)->())?
    var lastSelectedDate = Date()
    var schedualAction: (()->())?
    
    // MARK: - Initialization
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupFromNib()
    }
    
    
    private func setupFromNib() {
        guard let view = Self.nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            fatalError("Error loading \(self) from nib")
        }

        addSubview(view)
        view.frame = self.bounds
        superview?.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        superview?.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        superview?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        superview?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    // MARK: - Actions
    @IBAction func onDatePickerChange(_ sender: UIDatePicker) {
        if sender.date >= Calendar.current.date(byAdding: .day, value: -1, to: Date())!{
            lastSelectedDate = sender.date
        }else{
            sender.date = lastSelectedDate
        }   
    }
    
    @IBAction func onClickApplyBtn(_ sender: StyledButton) {
        dateBackgroundView.isHidden = true
        timeSlotView.isHidden = false
        reloadCell?(datePicker.date.toString(.custom("dd MMM, EEEE")))
    }
    
    @IBAction func onClickScheduleBtn(_ sender: StyledButton) {
        schedualAction?()
    }
    
    @IBAction func onCLickSelectedDate(_ sender: UIControl) {
        dateBackgroundView.isHidden = false
        timeSlotView.isHidden = true
        reloadCell?(nil)
    }
}
