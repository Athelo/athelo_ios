//
//  UserAvatarImageView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 24/06/2022.
//

import Combine
import UIKit

final class UserAvatarImageView: RoundedImageView {
    // MARK: - Properties
    private let tapSubject = PassthroughSubject<Void, Never>()
    var tapPublisher: AnyPublisher<Void, Never> {
        tapSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
        sink()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configure()
        sink()
    }
    
    static func instantiate() -> UserAvatarImageView {
        UserAvatarImageView(frame: CGRect(origin: .zero, size: CGSize(width: 32.0, height: 32.0)))
    }
    
    // MARK: - Configuration
    private func configure() {
        configureOwnView()
    }
    
    private func configureOwnView() {
        contentMode = .scaleAspectFit
        isUserInteractionEnabled = true
        
        widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        widthAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        weak var weakSelf = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: weakSelf, action: #selector(handleAvatarTap(_:)))
        
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoIdentityUtility()
    }
    
    private func sinkIntoIdentityUtility() {
        IdentityUtility.userDataPublisher
            .receive(on: DispatchQueue.main)
            .compactMap({ $0?.avatarImage(in: CGSize(width: 32.0, height: 32.0)) })
            .removeDuplicates()
            .sink { [weak self] in
                self?.displayLoadableImage($0)
            }.store(in: &cancellables)
    }
    
    // MARK: - Actions
    @objc private func handleAvatarTap(_ sender: Any?) {
        tapSubject.send()
    }
}
