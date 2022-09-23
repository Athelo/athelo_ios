//
//  StyledImageView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 18/07/2022.
//

import SwiftUI

struct StyledImageView: UIViewRepresentable {
    typealias UIViewType = UIImageView
    
    let imageData: LoadableImageData
    let contentMode: UIImageView.ContentMode
    let tintColor: UIColor?
    
    init(imageData: LoadableImageData, contentMode: UIImageView.ContentMode = .scaleAspectFill, tintColor: UIColor? = nil) {
        self.imageData = imageData
        self.contentMode = contentMode
        self.tintColor = tintColor
    }
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
    
        imageView.backgroundColor = .clear
        imageView.contentMode = contentMode
        imageView.tintColor = tintColor
        
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        switch imageData {
        case .image(let image):
            if tintColor != nil {
                uiView.image = image.withRenderingMode(.alwaysTemplate)
            } else {
                uiView.image = image
            }
        case .url(let url):
            uiView.sd_setImage(with: url) { image, _, _, _ in
                if self.tintColor != nil {
                    uiView.image = image?.withRenderingMode(.alwaysTemplate)
                }
            }
        }
    }
}
