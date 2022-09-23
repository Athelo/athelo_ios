//
//  NetworkingAPIErrorMessage+ErrorDetails.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 09/06/2022.
//

import Foundation
import OrderedCollections

extension NetworkingAPIErrorMessage {
    func combinedErrorMessage() -> String? {
        var messages = OrderedSet<String>()
        
        if !message.isEmpty {
            messages.append(message)
        }
        
        if let keys = extra?.keys {
            for key in keys {
                guard let value = extra?[key] else {
                    continue
                }
                
                if let errorMessages = value as? [String] {
                    messages.append(contentsOf: errorMessages.filter({ !$0.isEmpty }))
                } else if let errorMessage = value as? String, !errorMessage.isEmpty {
                    messages.append(errorMessage)
                }
            }
        }
        
        guard !messages.isEmpty else {
            return nil
        }
        
        return messages.joined(separator: " ")
    }
    
    func errorMessage(for key: String) -> String? {
        if let errorMessages = extra?[key] as? [String] {
            return errorMessages.joined(separator: " ")
        } else if let errorMessage = extra?[key] as? String {
            return errorMessage
        }
        
        return nil
    }
}
