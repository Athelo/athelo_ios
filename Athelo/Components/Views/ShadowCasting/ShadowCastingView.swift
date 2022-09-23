//
//  ShadowCastingView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 02/06/2022.
//

import UIKit

final class ShadowCastingView: UIView {
    // MARK: - Initialization
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    // MARK: - View lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateStyledShadowPaths()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureOwnView()
    }
    
    private func configureOwnView() {
        backgroundColor = .clear
    }
}
