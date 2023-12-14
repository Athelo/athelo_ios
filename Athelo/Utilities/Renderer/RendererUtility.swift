//
//  RendererUtility.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 09/06/2022.
//

import Foundation
import UIKit

protocol RendererAvatarSource {
    var rendererAvatarDisplayName: String? { get }
}

final class RendererUtility {
    // MARK: - Constants
    private typealias CacheImageIdentifier = NSString
    private enum CacheKey: String {
        case avatarPlaceholder
        case noImagePlaceholder

        func imageIdentifier(metadata: String) -> CacheImageIdentifier {
            "\(rawValue)-\(metadata)" as NSString
        }
    }

    enum BorderStyle: Hashable {
        case ellipse
        case roundedRect(CGFloat)
    }
    
    enum PlaceholderStyle: Hashable {
        case imageIcon
        case initials(BorderStyle)
    }
    
    // MARK: - Properties
    private static let instance = RendererUtility()

    private lazy var cache: NSCache<CacheImageIdentifier, UIImage> = {
        let cache = NSCache<CacheImageIdentifier, UIImage>()

        cache.totalCostLimit = 1_000_000

        return cache
    }()
    
    // MARK: - Public API
    static func renderAvatarPlaceholder(for source: RendererAvatarSource, size: CGSize, placeholderStyle: PlaceholderStyle = .initials(.ellipse)) -> UIImage {
        let displayedText = source.rendererAvatarDisplayName?.extractingInitials(maxLength: 2) ?? ""
        
        let metadata = "\(displayedText):\(size.width):\(size.height):\(placeholderStyle)"
        let imageIdentifier = CacheKey.avatarPlaceholder.imageIdentifier(metadata: metadata)

        if let cachedImage = instance.cache.object(forKey: imageIdentifier) {
            return cachedImage
        }

        let imageRenderer = UIGraphicsImageRenderer(size: size)
        let image = imageRenderer.image { context in
            context.fillEllipse(with: UIColor.withStyle(.background), in: CGRect(origin: .zero, size: size))
            
            switch placeholderStyle {
            case .imageIcon:
                let targetColor = UIColor.withStyle(.purple988098)
                let targetRect: CGRect = .init(
                    x: size.width / 4.0,
                    y: size.height / 4.0,
                    width: size.width / 2.0,
                    height: size.height / 2.0
                )
                
                context.cgContext.setFillColor(targetColor.cgColor)
                UIImage(named: "imageSolid")!.withRenderingMode(.alwaysTemplate).draw(in: targetRect)
            case .initials(let borderStyle):
                if !displayedText.isEmpty {
                    let font = UIFont.withStyle(.body).withSize(size.height * 0.4)
                    let textColor = UIColor.withStyle(.purple623E61)

                    let paragraph = NSMutableParagraphStyle()
                    paragraph.alignment = .center

                    let textAttributes: [NSAttributedString.Key: Any] = [
                        .font: font,
                        .foregroundColor: textColor,
                        .paragraphStyle: paragraph
                    ]

                    let encapsulatingTextSize = (displayedText as NSString).size(withAttributes: textAttributes)

                    let textOriginY = (size.height - encapsulatingTextSize.height) / 2.0
                    let textOriginX = min(0.0, (size.width - encapsulatingTextSize.width) / 2.0)
                    let textWidth = size.width + abs(textOriginX) * 2.0
                    let textRect = CGRect(x: textOriginX, y: textOriginY, width: textWidth, height: encapsulatingTextSize.height)

                    (displayedText as NSString).draw(in: textRect, withAttributes: textAttributes)
                }
                
                let strokeWidth = max(1.0, floor(size.height / 32.0))
                let strokeRect = CGRect(origin: .init(x: strokeWidth * 0.5, y: strokeWidth * 0.5), size: CGSize(width: size.width - strokeWidth, height: size.height - strokeWidth))
                
                switch borderStyle {
                case .ellipse:
                    context.strikeEllipse(with: UIColor.withStyle(.purple623E61), in: strokeRect, borderWidth: strokeWidth)
                case .roundedRect(let cornerRadius):
                    context.strikeRoundedRet(with: UIColor.withStyle(.purple623E61), in: strokeRect, cornerRadius: cornerRadius, borderWidth: strokeWidth)
                }
            }
        }

        let imageCost = image.pngData()?.count ?? 1_000
        instance.cache.setObject(image, forKey: imageIdentifier, cost: imageCost)

        return image
    }
    
    static func renderNoImagePlaceholder(forHeight height: CGFloat) -> UIImage {
        let metadata = "\(Int(height))"
        let imageIdentifier = CacheKey.noImagePlaceholder.imageIdentifier(metadata: metadata)
        
        if let cachedImage = instance.cache.object(forKey: imageIdentifier) {
            return cachedImage
        }
        
        let wavesBackgroundImage = UIImage(named: "wavesBackground")!
        let logoImage = UIImage(named: "logoSmall")!
        
        let targetScale = max(1.0, height / wavesBackgroundImage.size.height)
        let targetWidth = wavesBackgroundImage.size.width * targetScale
        let targetSize = CGSize(width: targetWidth, height: height)
        
        let view = UIView(frame: .init(origin: .zero, size: targetSize))
        view.backgroundColor = .clear
        
        let wavesBackgroundImageView = UIImageView(image: wavesBackgroundImage)
        wavesBackgroundImageView.alpha = 0.3
        
        let logoImageView = UIImageView(image: logoImage)
        
        view.addSubview(wavesBackgroundImageView)
        view.addSubview(logoImageView)
        
        let viewCenter = CGPoint(x: view.center.x, y: view.center.y)
        wavesBackgroundImageView.center = CGPoint(
            x: viewCenter.x + 20.0,
            y: viewCenter.y - 10.0
        )
        logoImageView.center = viewCenter
        
        let imageRenderer = UIGraphicsImageRenderer(size: targetSize)
        let image = imageRenderer.image { context in
            view.layer.render(in: context.cgContext)
        }
        
        let imageCost = image.pngData()?.count ?? 1_000
        instance.cache.setObject(image, forKey: imageIdentifier, cost: imageCost)
        
        return image
    }
}

private extension UIGraphicsImageRendererContext {
    func fillEllipse(with color: UIColor, in rect: CGRect) {
        cgContext.setFillColor(color.cgColor)

        cgContext.beginPath()
        cgContext.addEllipse(in: rect)
        cgContext.closePath()

        cgContext.fillPath()
    }
    
    func strikeEllipse(with color: UIColor, in rect: CGRect, borderWidth: CGFloat = 1.0) {
        cgContext.setStrokeColor(color.cgColor)
        
        cgContext.beginPath()
        cgContext.addEllipse(in: rect)
        cgContext.closePath()
        
        cgContext.setLineWidth(borderWidth)
        cgContext.strokePath()
    }
    
    func strikeRoundedRet(with color: UIColor, in rect: CGRect, cornerRadius: CGFloat, borderWidth: CGFloat = 1.0) {
        cgContext.setStrokeColor(color.cgColor)
        
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        
        cgContext.beginPath()
        cgContext.addPath(path.cgPath)
        cgContext.closePath()
        
        cgContext.setLineWidth(borderWidth)
        cgContext.strokePath()
    }
}
