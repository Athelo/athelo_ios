//
//  UIWindow+CustomOverlays.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/03/2023.
//

import Foundation
import SwiftUI
import UIKit

enum ViewPinningTags: Int {
    case selectContact = 10
    case optionSheet
}

extension WindowOverlayUtility {
    @MainActor func displayOptionSheetView(with actions: [OptionSheetItem]) {
        let optionSheetModel = OptionSheetModel(actions: actions)
        let optionSheetView = OptionSheetView(model: optionSheetModel)
        
        displayCustomOverlayView(optionSheetView, animated: true) { pinnedView, superview in
            pinnedView.tag = ViewPinningTags.optionSheet.rawValue
            
            superview.addSubview(pinnedView)
            pinnedView.stretchToSuperview()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            optionSheetModel.toggleVisibility()
        }
    }
    
    @MainActor func displayWardSelectionView(animated: Bool = true) {
        guard IdentityUtility.activeUserRole?.relatedPatientData != nil else {
            return
        }
        
        let selectContactView = SelectContactView(
            contacts: IdentityUtility.patients ?? [],
            selectedContact: IdentityUtility.activeUserRole?.relatedPatientData,
            onContactSelected: { contact in
                if let patient = (contact as? RelationInterpretationData)?.relatedPerson {
                    IdentityUtility.switchActiveRole(.caregiver(patient))
                }
                
                AppRouter.current.windowOverlayUtility.hideCustomOverlayView(withPinningTag: ViewPinningTags.selectContact)
            }, onCancel: {
                AppRouter.current.windowOverlayUtility.hideCustomOverlayView(withPinningTag: ViewPinningTags.selectContact)
            }
        )
        
        displayCustomOverlayView(selectContactView, animated: animated) { pinnedView, superview in
            pinnedView.translatesAutoresizingMaskIntoConstraints = false
            superview.addSubview(pinnedView)
            
            pinnedView.tag = ViewPinningTags.selectContact.rawValue
            
            NSLayoutConstraint.activate([
                pinnedView.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                pinnedView.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
                pinnedView.widthAnchor.constraint(equalTo: superview.widthAnchor),
                pinnedView.heightAnchor.constraint(equalTo: superview.heightAnchor)
            ])
            
            pinnedView.setNeedsLayout()
            pinnedView.layoutIfNeeded()
        }
    }
}
