//
//  AppointmnetCalanderView.swift
//  Athelo
//
//  Created by Devsto on 02/02/24.
//

import Foundation
import UIKit

final class AppointmnetCalanderView: UIView{
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var timeSlotView: UIView!
    @IBOutlet weak var dateBackgroundView: UIView!
    @IBOutlet weak var selectedDateView: UIView!
    
    
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
    
}
