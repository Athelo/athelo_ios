//
//  NoAppointment.swift
//  Athelo
//
//  Created by Devsto on 30/01/24.
//

import Combine
import UIKit


final class NoAppointment: UIView{
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
