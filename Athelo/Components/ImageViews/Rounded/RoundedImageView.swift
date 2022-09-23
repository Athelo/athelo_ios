//
//  RoundedImageView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 09/06/2022.
//

import UIKit

class RoundedImageView: UIImageView {
    // MARK: - View lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()

        updateCorners()
    }

    // MARK: - Updates
    private func updateCorners() {
        layer.masksToBounds = true
        layer.cornerRadius = min(bounds.width, bounds.height) / 2.0
    }
}
