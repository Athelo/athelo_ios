//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 30/05/2022.
//

import Foundation

public enum APIError: Error {
    case missingCredentials
    case decodingError
    case invalidRequest
    case invalidResponse
    case httpError(Int, NetworkingAPIErrorMessage)
    case error(Error)
    case unknown
    case message(NetworkingAPIErrorMessage)

    static func convertToAPIError(_ error: Error) -> APIError {
        if let apiError = error as? APIError {
            return apiError
        }

        return .error(error)
    }

    init(data: Data, statusCode: Int? = nil) throws {
        let error = try JSONDecoder().decode(NetworkingAPIErrorMessage.self, from: data)

        if let statusCode = statusCode {
            self = .httpError(statusCode, error)
        } else {
            self = .message(error)
        }
    }

    init(message: String, statusCode: Int? = nil) throws {
        let error = NetworkingAPIErrorMessage(message: message)

        if let statusCode = statusCode {
            self = .httpError(statusCode, error)
        } else {
            self = .message(error)
        }
    }
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .missingCredentials:
            return "This operation is available only for authenticated users."
        case .decodingError, .invalidRequest, .invalidResponse, .unknown:
            return "There was a problem with processing your request. Please check your internet connection and try again later."
        case .message(let error):
            return error.message
        case .httpError(_, let error):
            return error.message
        case .error(let error):
            return error.localizedDescription
        }
    }
}

public struct NetworkingAPIErrorMessage: Decodable {
    public let errorCode: Int
    public let extra: [String: Any]?
    public let message: String

    private enum CodingKeys: String, CodingKey {
        case detail, details, extra
        case detailsJSON = "details_json"
        case errorCode = "error_code"
        case errorInformation = "error_information"
    }

    init(message: String) {
        self.errorCode = -101
        self.extra = nil
        self.message = message
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.errorCode = try container.decodeValue(forKey: .errorCode)

        var messages: [String] = []
        if let detail: String = try? container.decodeValue(forKey: .detail), !detail.isEmpty {
            messages.append(detail)
        }

        var targetExtra: [String: Any] = [:]
        // If value for `.extra` is just a string, accept it as an error message.
        if let exception: String = try? container.decodeValue(forKey: .extra) {
            messages.append(exception)
        // If value for `.extra` is a JSON value...
        } else if let expectionJSON: JSONDataTypeValue = try? container.decodeValue(forKey: .extra) {
            //...and that JSON value is a string, accept it as an error message.
            if case .string(let value) = expectionJSON, !value.isEmpty {
                messages.append(value)
            //...and that JSON value is a dictionary that has String `.exception` value...
            } else if case .dict(let json) = expectionJSON,
                      let exceptionData = NetworkingAPIErrorMessage.nestedErrorData(from: json) {
                //...which can be treated as an API error instance, add messages from such error into known error messages...
                if let nestedError = try? JSONDecoder().decode(NetworkingAPIErrorMessage.self, from: exceptionData) {
                    messages.removeAll()
                    messages.append(nestedError.message)
                    //...and if it has any extra data, treat it as own extra data.
                    if let extra = nestedError.extra, !extra.isEmpty {
                        targetExtra = extra
                    }
                }
            }
        // If value for `.extra` is anything else (or nothing at all)...
        } else {
            //...but a valid JSON value of dictionary type exists under `.details` key, treat it as error extra data.
            if let detailsJSON: JSONDataTypeValue = (try? container.decodeValue(forKey: .details)) ?? (try? container.decodeValue(forKey: .detail)),
               case .dict(let json) = detailsJSON {
                targetExtra = json.jsonDict()
            }
        }

        if let errorInformation: String = try? container.decodeValue(forKey: .errorInformation), !errorInformation.isEmpty {
            messages.append(errorInformation)
        }
        
        if let detailsJSONValue: JSONDataTypeValue = try? container.decodeValue(forKey: .detailsJSON),
           case .dict(let json) = detailsJSONValue {
            let jsonDict = json.jsonDict()
            
            for (key, _) in jsonDict {
                if let messages = (jsonDict[key] as? [String])?.filter({ !$0.isEmpty }), !messages.isEmpty {
                    if (targetExtra[key] as? [String]) != nil {
                        targetExtra[key] = ((targetExtra[key] as? [String]) ?? []) + messages
                    } else if let currentMessage = targetExtra[key] as? String, !currentMessage.isEmpty {
                        targetExtra[key] = messages + [currentMessage]
                    } else {
                        targetExtra[key] = messages
                    }
                } else if let message = jsonDict[key] as? String, !message.isEmpty {
                    if (targetExtra[key] as? [String]) != nil {
                        targetExtra[key] = (targetExtra[key] as? [String] ?? []) + [message]
                    } else {
                        targetExtra[key] = message
                    }
                }
            }
        }

        self.extra = targetExtra
        self.message = messages.joined(separator: " ")
    }
    
    private static func nestedErrorData(from json: [String: JSONDataTypeValue]) -> Data? {
        if let exceptionString = json.jsonDict()["exception"] as? String,
           let exceptionData = exceptionString.replacingOccurrences(of: "'", with: "\"").data(using: .utf8) {
            return exceptionData
        }
        
        if let nestedErrorData = json.jsonDict()["exception"] as? [String: Any],
           let exceptionData = try? JSONSerialization.data(withJSONObject: nestedErrorData, options: []) {
            return exceptionData
        }
        
        return nil
    }
}
