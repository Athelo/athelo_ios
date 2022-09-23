//
//  IntroWomenView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 07/06/2022.
//

import UIKit

final class IntroWomenView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var imageViewWomen: UIImageView!
    
    // MARK: - Initialization
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupFromNib()
        
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupFromNib()
        
        configure()
    }
    
    private func setupFromNib() {
        guard let view = Self.nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            fatalError("Error loading \(self) from nib")
        }

        addSubview(view)
        view.frame = self.bounds
        
        superview?.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        superview?.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        superview?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        superview?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    // MARK: - View lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateMask()
    }
    
    // MARK: - Public API
    func updateProgress(_ progress: Double) {
        let targetProgress = abs(max(0.0, min(1.0, progress)))
        
        let startCenterOffset = CGPoint(x: 45.0, y: 140.0)
        let midCenterOffset = CGPoint(x: 60.0, y: 220.0)
        let endCenterOffset = CGPoint(x: 180.0, y: 240.0)
        
        var startPoint: CGPoint
        var endPoint: CGPoint
        var diff: Double
        
        if targetProgress <= 0.5 {
            startPoint = startCenterOffset
            endPoint = midCenterOffset
            
            diff = targetProgress * 2.0
        } else {
            startPoint = midCenterOffset
            endPoint = endCenterOffset
            
            diff = (targetProgress - 0.5) * 2.0
        }
        
        let targetX = startPoint.x + (endPoint.x - startPoint.x) * diff
        let targetY = startPoint.y + (endPoint.y - startPoint.y) * diff
        let targetPoint = CGPoint(x: targetX, y: targetY)
        
        imageViewWomen.center = targetPoint
    }
    
    // MARK: - Configuration
    private func configure() {
        configureWomenImageView()
    }
    
    private func configureWomenImageView() {
        DispatchQueue.main.async { [weak self] in
            self?.imageViewWomen.center = CGPoint(x: 0.0, y: 140.0)
        }
    }
    
    // MARK: - Updates
    private func updateMask() {
        guard let image = UIImage(named: "introBlob") else {
            return
        }
        
        let ratio = image.size.width / image.size.height
        
        var imageCanvasRect: CGRect
        if ratio > 1.0 {
            let targetHeight = bounds.size.height / ratio
            let targetY = (bounds.size.height - targetHeight) / 2.0
            
            imageCanvasRect = .init(origin: .init(x: 0.0, y: targetY), size: .init(width: bounds.size.width, height: targetHeight))
        } else {
            let targetWidth = bounds.size.width * ratio
            let targetX = (bounds.size.width - targetWidth) / 2.0
            
            imageCanvasRect = .init(origin: .init(x: targetX, y: 0.0), size: .init(width: targetWidth, height: bounds.size.height))
        }
        
        let maskImage = UIGraphicsImageRenderer(bounds: bounds).image { context in
            image.draw(in: imageCanvasRect)
        }
        
        let maskLayer = CALayer()
        maskLayer.frame = bounds
        maskLayer.contents = maskImage.cgImage
        
        layer.mask = maskLayer
    }
}
