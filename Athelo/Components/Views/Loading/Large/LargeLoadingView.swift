//
//  LargeLoadingView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 06/06/2022.
//

import UIKit
import SwiftUI

final class LargeLoadingView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var visualEffectViewContainer: UIVisualEffectView!
    @IBOutlet private weak var viewDotsHosting: UIView!
    
    // MARK: - View lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureContainerView()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureContainerView()
    }
    
    private func configureContainerView() {
        visualEffectViewContainer.layer.masksToBounds = true
        visualEffectViewContainer.layer.cornerRadius = 24.0
    }
}
