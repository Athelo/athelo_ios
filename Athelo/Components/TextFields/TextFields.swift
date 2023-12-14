//
//  TextFields.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 02/09/2022.
//

import Combine
import Foundation
import UIKit

protocol ThemedTextField: UITextField {
    var style: UIFont.AppStyle { get }
    
    func applyStyling()
}

extension ThemedTextField {
    func applyStyling() {
        font = .withStyle(style)
    }
}

class BaseStyledTextField: UITextField {
    private let deleteBackwardSubject = PassthroughSubject<UITextField, Never>()
    var deleteBackwardPublisher: AnyPublisher<UITextField, Never> {
        deleteBackwardSubject.eraseToAnyPublisher()
    }
    
    override func deleteBackward() {
        super.deleteBackward()
        
        deleteBackwardSubject.send(self)
    }
}

final class ParagraphTextField: BaseStyledTextField, ThemedTextField {
    var style: UIFont.AppStyle {
        .paragraph
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        applyStyling()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyStyling()
    }
}
