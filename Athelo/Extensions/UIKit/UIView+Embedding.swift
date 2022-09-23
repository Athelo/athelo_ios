//
//  UIView+Embedding.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 30/05/2022.
//

import UIKit

extension UIView {
    func addAndStretch(to superview: UIView, inSafeArea: Bool = false) {
        superview.addSubview(self)
        stretchToSuperview(inSafeArea: inSafeArea)
    }

    func stretchToSuperview(inSafeArea: Bool = false) {
        guard let superview = superview else {
            return
        }

        translatesAutoresizingMaskIntoConstraints = false

        if inSafeArea {
            NSLayoutConstraint.activate([
                topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor),
                bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor),
                leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor),
                trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                topAnchor.constraint(equalTo: superview.topAnchor),
                bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                trailingAnchor.constraint(equalTo: superview.trailingAnchor)
            ])
        }
    }
}
