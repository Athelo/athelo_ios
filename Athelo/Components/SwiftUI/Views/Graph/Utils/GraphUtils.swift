//
//  GraphUtils.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 11/08/2022.
//

import Foundation
import SwiftUI

enum GraphUtils {
    // MARK: - Public API
    static func adjustOverlayCenterPoint(_ point: CGPoint, inside size: CGSize, overlaySize: CGSize) -> CGPoint {
        var targetCoordinates = point
        
        if targetCoordinates.x - overlaySize.width / 2.0 < 0.0 {
            let diffX = abs(targetCoordinates.x - overlaySize.width / 2.0)
            targetCoordinates.x += diffX
        } else if targetCoordinates.x + overlaySize.width / 2.0 > size.width {
            let diffX = size.width - (targetCoordinates.x + overlaySize.width / 2.0)
            targetCoordinates.x += diffX
        }
        
        if targetCoordinates.y - overlaySize.height / 2.0 < 0.0 {
            let diffY = abs(targetCoordinates.y - overlaySize.height / 2.0)
            targetCoordinates.y += diffY
        } else if targetCoordinates.y + overlaySize.height / 2.0 > size.height {
            let diffY = size.height - (targetCoordinates.y + overlaySize.height / 2.0)
            targetCoordinates.y += diffY
        }
        
        return targetCoordinates
    }
    
    static var gridColor: UIColor {
        .withStyle(.lightGray).withAlphaComponent(0.2)
    }
    
    static var gridStrokeStyle: StrokeStyle {
        .init(lineWidth: 1.0, lineCap: .round, lineJoin: .bevel, miterLimit: 0.0, dash: [10.0, 10.0], dashPhase: 0.0)
    }
    
    static func overlaySize(for label: String?, secondaryLabel: String?) -> CGSize {
        var size = CGSize(width: 16.0, height: 16.0)
        
        var labelSize = CGSize.zero
        if let label = label {
            labelSize = NSString(string: label).boundingRect(with: .init(width: .greatestFiniteMagnitude, height: 1.0), options: [.usesLineFragmentOrigin], attributes: attributes(for: .withStyle(.subtitle)), context: nil).size
        }
        
        var sublabelSize = CGSize.zero
        if let label = secondaryLabel {
            sublabelSize = NSString(string: label).boundingRect(with: .init(width: .greatestFiniteMagnitude, height: 1.0), options: [.usesLineFragmentOrigin], attributes: attributes(for: .withStyle(.subtitle)), context: nil).size
        }
        
        size.height += max(labelSize.height, sublabelSize.height)
        size.width += labelSize.width
        if sublabelSize.width > 0.0 {
            size.width += 4.0 + sublabelSize.width
        }
        
        return size
    }
    
    // MARK: - Helpers
    private static func attributes(for font: UIFont) -> [NSAttributedString.Key: Any] {
        var attrs: [NSAttributedString.Key: Any] = [:]
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineHeightMultiple = 1.24
        
        attrs[.baselineOffset] = abs(font.ascender - font.capHeight) / 2.0
        attrs[.font] = font
        attrs[.paragraphStyle] = paragraph
        
        return attrs
    }
}
