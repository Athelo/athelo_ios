//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 30/05/2022.
//

import Combine
import Foundation

protocol APIServiceProtocol {
    func request(with builder: APIBuilderProtocol) -> AnyPublisher<Never, APIError>
    func request<T: Decodable>(with builder: APIBuilderProtocol) -> AnyPublisher<T, APIError>
}

struct APIService: APIServiceProtocol {
    func request(with builder: APIBuilderProtocol) -> AnyPublisher<Never, APIError> {
        dataTaskPublisher(for: builder)
            .ignoreOutput()
            .eraseToAnyPublisher()
    }


    func request<T>(with builder: APIBuilderProtocol) -> AnyPublisher<T, APIError> where T : Decodable {
        dataTaskPublisher(for: builder)
            .tryMap({ data -> T in
                do {
                    let requestData = try JSONDecoder().decode(T.self, from: data)
                    return requestData
                } catch let error {
                    #if DEBUG
                    debugPrint(error)
                    #endif

                    throw APIError.convertToAPIError(error)
                }
            })
            .mapError({ APIError.convertToAPIError($0) })
            .eraseToAnyPublisher()
    }

    private func dataTaskPublisher(for builder: APIBuilderProtocol) -> AnyPublisher<Data, APIError> {
        let request = builder.buildURLRequest()

        #if DEBUG
        if let requestURL = request.url {
            debugPrint(builder.method.rawValue, requestURL)
        }
        #endif

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap({ data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    let thrownError = APIError.invalidResponse

                    #if DEBUG
                    if let requestURL = response.url {
                        debugPrint(builder.method.rawValue, requestURL, thrownError)
                    }
                    #endif

                    throw thrownError
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    if let error = try? APIError(data: data, statusCode: httpResponse.statusCode) {
                        throw error
                    }

                    let thrownError = APIError.httpError(httpResponse.statusCode, NetworkingAPIErrorMessage(message: "An error has occured. Please check your internet connection and try again later."))

                    #if DEBUG
                    if let requestURL = response.url {
                        debugPrint(builder.method.rawValue, requestURL, thrownError)
                    }
                    #endif

                    throw thrownError
                }
                
                #if DEBUG
                if let responseData = data.prettyPrintedJSONString {
                    debugPrint(responseData)
                }
                #endif
                
                return data
            })
            .mapError({ APIError.convertToAPIError($0) })
            .eraseToAnyPublisher()
    }
}
extension Data {
    var prettyPrintedJSONString: NSString? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: jsonObject,
                                                       options: [.prettyPrinted]),
              let prettyJSON = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else {
                  return nil
               }

        return prettyJSON
    }
}
