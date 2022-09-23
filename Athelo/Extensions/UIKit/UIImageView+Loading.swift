//
//  UIImageView+Loading.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 09/06/2022.
//

import Foundation
import SDWebImage
import UIKit

extension UIImageView {
    func displayLoadableImage(_ imageData: LoadableImageData, placeholder: UIImage? = nil, renderingMode: UIImage.RenderingMode? = nil, completion: ((Bool) -> Void)? = nil) {
        switch imageData {
        case .image(let image):
            var image = image
            if let renderingMode = renderingMode, image.renderingMode != renderingMode {
                image = image.withRenderingMode(renderingMode)
            }
            
            self.image = image
            
            completion?(true)
        case .url(let url):
            sd_setImage(with: url, placeholderImage: placeholder) { image, _, _, _ in
                DispatchQueue.main.async {
                    completion?(image != nil)
                }
            }
        }
    }
}
