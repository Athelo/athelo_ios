//
//  PopupView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 13/06/2022.
//

import UIKit

typealias PopupActionData = PopupView.ActionData
typealias PopupConfigurationData = PopupView.ConfigurationData

final class PopupView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var buttonClose: UIButton!
    @IBOutlet private weak var buttonPrimaryAction: StyledButton!
    @IBOutlet private weak var buttonSecondaryAction: StyledButton!
    @IBOutlet private weak var labelMessage: UILabel!
    @IBOutlet private weak var labelTitle: UILabel!
    
    // MARK: - Properties
    private weak var overlayContainer: UIView?
    
    private var primaryAction: (() -> Void)? = nil
    private var secondaryAction: (() -> Void)? = nil
    
    // MARK: - Public API
    func assignOverlayContainer(_ overlayContainer: UIView) {
        self.overlayContainer = overlayContainer
    }
    
    func configure(using data: PopupConfigurationData) {
        labelTitle.text = data.title
        labelMessage.attributedText = data.message
        
        labelMessage.isHidden = !(data.message?.string.isEmpty == false)
        
        primaryAction = data.primaryAction.action
        
        buttonPrimaryAction.style = data.primaryAction.customStyle ?? .main
        buttonPrimaryAction.setTitle(data.primaryAction.title, for: .normal)
        
        if let secondaryAction = data.secondaryAction {
            self.secondaryAction = secondaryAction.action
            
            buttonSecondaryAction.style = data.secondaryAction?.customStyle ?? .secondary
            buttonSecondaryAction.setTitle(secondaryAction.title, for: .normal)
        } else {
            self.secondaryAction = nil
            buttonSecondaryAction.isHidden = true
        }
        
        buttonClose.isHidden = !data.displaysCloseButton
    }
    
    // MARK: - Updates
    private func hide() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            if let overlayContainer = self?.overlayContainer as? UIWindow {
                overlayContainer.hidePopupView()
            } else {
                self?.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Actions
    @IBAction private func closeButtonTapped(_ sender: Any) {
        hide()
    }
    
    @IBAction private func primaryActionButtonTapped(_ sender: Any) {
        primaryAction?()
        hide()
    }
    
    @IBAction private func secondaryActionButtonTapped(_ sender: Any) {
        secondaryAction?()
        hide()
    }
}

// MARK: - Helper extensions
extension PopupView {
    enum ConfigurationTemplate: String {
        case deleteAccount = "deleteaccount"
        case disconnectDevice = "disconnectdevice"
        case deleteSymptom = "deletesymptom"
        case leaveCommunity = "leavecommunity"
        case logOut = "logout"
        case selectPhoto = "selectphoto"
        case cancelAppointment = "cancelAppointment"
        case reschedual = "reschedule"
    }
    
    struct ActionData {
        let title: String
        let action: (() -> Void)?
        let customStyle: StyledButton.Style?
        
        init(title: String, customStyle: StyledButton.Style? = nil, action: (() -> Void)? = nil) {
            self.title = title
            self.action = action
            self.customStyle = customStyle
        }
    }
    
    struct ConfigurationData {
        let title: String
        let message: NSAttributedString?
        var displaysCloseButton: Bool
        let primaryAction: PopupActionData
        let secondaryAction: PopupActionData?
        
        init(title: String, message: String? = nil, displaysCloseButton: Bool = false, primaryAction: PopupActionData = .init(title: "OK"), secondaryAction: PopupActionData? = nil) {
            self.title = title
            
            if let message {
                self.message = NSAttributedString(string: message)
            } else {
                self.message = nil
            }
            
            self.displaysCloseButton = displaysCloseButton
            
            self.primaryAction = primaryAction
            self.secondaryAction = secondaryAction
        }
        
        init(template: ConfigurationTemplate, primaryAction: PopupActionData = .init(title: "OK"), secondaryAction: PopupActionData? = nil) {
            self.title = template.title
            self.message = NSAttributedString(string: template.message)
            self.displaysCloseButton = template.displaysCloseButton
            if template == .cancelAppointment || template == .reschedual{
                self.displaysCloseButton = false
            }
            
            self.primaryAction = primaryAction
            self.secondaryAction = secondaryAction
        }
        
        init(title: String, message: NSAttributedString? = nil, displaysCloseButton: Bool = false, primaryAction: PopupActionData = .init(title: "OK"), secondaryAction: PopupActionData? = nil) {
            self.title = title
            self.message = message
            self.displaysCloseButton = displaysCloseButton
            
            self.primaryAction = primaryAction
            self.secondaryAction = secondaryAction
        }
    }
}

private extension PopupView.ConfigurationTemplate {
    var message: String {
        "popup.\(rawValue).message".localized()
    }
    
    var title: String {
        "popup.\(rawValue).title".localized()
    }
    
    var displaysCloseButton: Bool {
        switch self {
        case .deleteAccount, .deleteSymptom, .disconnectDevice, .leaveCommunity, .logOut:
            return false
        case .selectPhoto, .cancelAppointment, .reschedual:
            return true
        }
    }
}
