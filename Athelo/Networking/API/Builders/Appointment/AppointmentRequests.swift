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
        
        public static func getAllProviders<T: Decodable>() -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.providers).eraseToAnyPublisher()
        }
        
        static func getProviderAvability(request: ProviderAvabilityRequest) -> AnyPublisher<ProviderAvability, APIError> {
            APIService().request(with: Builder.providerAvability(request: request)).eraseToAnyPublisher()
        }
     
        public static func bookAppointment(request: BookAppoointmentRequest) -> AnyPublisher<Never, APIError>{
            APIService().request(with: Builder.bookAppointment(request: request)).eraseToAnyPublisher()
        }
        
        static func getAllAppointments() -> AnyPublisher<AppoitmentResponseData, APIError>{
            APIService().request(with: Builder.getAppointments).eraseToAnyPublisher()
        }
        
        static func delete(request: DeleteAppointmentRequest) -> AnyPublisher<Never, APIError>{
            APIService().request(with: Builder.delete(request: request)).eraseToAnyPublisher()
        }
        
        static func getAppointmentDetail(request: JoinAppointmentRequest) -> AnyPublisher<AppointmetntData, APIError>{
            APIService().request(with: Builder.appointmentDetail(request: request)).eraseToAnyPublisher()
        }
        
        static func getVonageDetail(request: JoinAppointmentRequest) -> AnyPublisher<VonageData, APIError>{
            APIService().request(with: Builder.vonageKey(request: request)).eraseToAnyPublisher()
        }
        
    }
}
