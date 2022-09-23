//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 28/06/2022.
//

import Foundation

extension URL {
    static func docsPath(for fileName: String) throws -> URL {
        guard let rootPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw URLError(.cannotCreateFile, userInfo: [:])
        }
        
        return rootPath.appendingPathComponent(fileName)
    }
}
