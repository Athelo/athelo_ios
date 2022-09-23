//
//  ImageCacheUtility.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 21/06/2022.
//

import Foundation
import SDWebImage

final class ImageCacheUtility {
    // MARK: - Properties
    private static var cacheURLStrippingRule: (URL) -> String = { url in
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return url.absoluteString
        }
        
        urlComponents.query = nil
        
        return (urlComponents.url ?? url).absoluteString
    }
    
    // MARK: - Public API
    static func setupCachingRules() {
        SDWebImageManager.shared.cacheKeyFilter = SDWebImageCacheKeyFilter(block: cacheURLStrippingRule)
    }
}
