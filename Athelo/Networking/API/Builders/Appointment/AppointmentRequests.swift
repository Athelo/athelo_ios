//
//  AppointmentRequests.swift
//  Athelo
//
//  Created by Devsto on 05/02/24.
//

import Combine
import Foundation

public extension AtheloAPI {
    enum Appointment {
        private typealias Builder = AppointmentRequestBuilder
        
        public static func getAllProviders() -> AnyPublisher<Never, APIError> {
            APIService().request(with: Builder.providers).eraseToAnyPublisher()
        }
        
    }
}
