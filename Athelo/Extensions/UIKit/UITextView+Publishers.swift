//
//  UITextView+Publishers.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 03/11/2022.
//

import Combine
import CombineCocoa
import UIKit

extension UITextView {
    var currentTextPublisher: AnyPublisher<String?, Never> {
        if #available(iOS 16.0, *) {
            return textPublisher
                .debounce(for: .init(floatLiteral: 1.0 / 120.0), scheduler: DispatchQueue.main)
                .map({ [weak self] _ in
                    self?.text
                })
                .eraseToAnyPublisher()
        } else {
            return textPublisher
        }
    }
}
