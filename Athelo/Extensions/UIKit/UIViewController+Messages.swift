//
//  UIViewController+Messages.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 19/07/2022.
//

import UIKit

extension UIViewController {
    func dismissMessage() {
        AppRouter.current.windowOverlayUtility.dismissMessage()
    }
    
    func displayError(_ error: Error) {
        displayMessage(error.toInfoMessageData())
    }
    
    func displayMessage(_ message: String, type: InfoMessageData.MessageType = .plain) {
        AppRouter.current.windowOverlayUtility.displayMessage(message, type: type)
    }
    
    func displayMessage(_ message: InfoMessageData) {
        AppRouter.current.windowOverlayUtility.displayMessage(message.text, type: message.type)
    }
}
