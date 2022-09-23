//
//  UIImage+Filters.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 11/07/2022.
//

import Foundation
import UIKit

extension UIImage {
    func applyGaussianBlur(blurRadius: Double = 13.0) -> UIImage? {
        guard let ciImage = CIImage(image: self),
              let gaussianBlurFilter = CIFilter(name: "CIGaussianBlur") else {
            return nil
        }
        
        gaussianBlurFilter.setValue(ciImage, forKey: kCIInputImageKey)
        gaussianBlurFilter.setValue(NSNumber(value: max(0.0, blurRadius)), forKey: kCIInputRadiusKey)
        
        guard let blurredImage = gaussianBlurFilter.outputImage else {
            return nil
        }
        
        let targetImage = UIImage(ciImage: blurredImage)
        return targetImage
    }
    
    /// Resturns an average color of whole image.
    ///
    /// - Returns: Average color, if successful.
    func getAverageColor() -> UIColor? {
        guard let ciImage = CIImage(image: self),
              let averageFilter = CIFilter(name: "CIAreaAverage") else {
            return nil
        }
        
        let extentRect = CGRect(origin: ciImage.extent.origin, size: ciImage.extent.size)
        let extentVector = CIVector(cgRect: extentRect)
        
        averageFilter.setValue(ciImage, forKey: kCIInputImageKey)
        averageFilter.setValue(extentVector, forKey: kCIInputExtentKey)
        
        guard let averageCIImage = averageFilter.outputImage else {
            return nil
        }
        
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        var bitmap = [UInt8](repeating: 0, count: 4)
        
        let pixelRect = CGRect(origin: .zero, size: CGSize(width: 1.0, height: 1.0))
        context.render(averageCIImage, toBitmap: &bitmap, rowBytes: 4, bounds: pixelRect, format: .RGBA8, colorSpace: nil)
        
        return UIColor(red: CGFloat(bitmap[0]) / 255.0,
                       green: CGFloat(bitmap[1]) / 255.0,
                       blue: CGFloat(bitmap[2]) / 255.0,
                       alpha: CGFloat(bitmap[3]) / 255.0)
    }
}
