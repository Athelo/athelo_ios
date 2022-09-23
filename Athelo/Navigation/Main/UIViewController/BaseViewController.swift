//
//  BaseViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 31/05/2022.
//

import UIKit

class BaseViewController: UIViewController {
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureOwnView()
    }
    
    private func configureOwnView() {
        view.backgroundColor = .withStyle(.background)
    }
}
