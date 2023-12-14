//
//  WaveBackgroundView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 20/03/2023.
//

import SwiftUI

struct WaveBackgroundView: UIViewRepresentable {
    let offset: CGPoint
    
    init(offset: CGPoint = .zero) {
        self.offset = offset
    }
    
    func makeUIView(context: Context) -> UIView {
        let imageView = UIImageView()
        
        imageView.image = UIImage(named: "wavesBackground")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = false
        
        let containerView = UIView()
        
        containerView.backgroundColor = .clear
        
        containerView.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: offset.x),
            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: offset.y)
        ])
        
        containerView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        containerView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        /* ... */
    }
}
