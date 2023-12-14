//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 14/07/2022.
//

import Combine
import Foundation

public extension AtheloAPI {
    enum Health {
        private typealias Builder = HealthRequestBuilder
        
        public static func acceptCaregiverInvitation(request: HealthAcceptCaregiverInvitationRequest) -> AnyPublisher<Never, APIError> {
            APIService().request(with: Builder.acceptCaregiverInvitation(request: request)).eraseToAnyPublisher()
        }
        
        public static func activityDashboard<T: Decodable>(request: HealthActivityDashboardRequest) -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.activityDashboard(request: request)).eraseToAnyPublisher()
        }
        
        public static func addUserFeeling<T: Decodable>(request: HealthAddFeelingRequest) -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.addUserFeeling(request: request)).eraseToAnyPublisher()
        }
        
        public static func addUserSymptom<T: Decodable>(request: HealthAddSymptomRequest) -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.addUserSymptom(request: request)).eraseToAnyPublisher()
        }
 
        public static func cancelInvitation(request: HealthCancelInvitationRequest) -> AnyPublisher<Never, APIError> {
            APIService().request(with: Builder.cancelInvitation(request: request)).eraseToAnyPublisher()
        }
        
        public static func caregiversList<T: Decodable>() -> AnyPublisher<ListResponseData<T>, APIError> {
            APIService().request(with: Builder.caregiverList).eraseToAnyPublisher()
        }
        
        public static func createSymptom<T: Decodable>(request: HealthCreateSymptomRequest) -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.createSymptom(request: request)).eraseToAnyPublisher()
        }
        
        public static func dashboard<T: Decodable>(request: HealthDashboardRequest) -> AnyPublisher<[T], APIError> {
            APIService().request(with: Builder.dashboard(request: request))
        }
        
        public static func deleteSymptom(request: HealthDeleteSymptomRequest) -> AnyPublisher<Never, APIError> {
            APIService().request(with: Builder.deleteSymptom(request: request)).eraseToAnyPublisher()
        }
        
        public static func invitationList<T: Decodable>(request: HealthInvitationsRequest) -> AnyPublisher<ListResponseData<T>, APIError> {
            APIService().request(with: Builder.invitations(request: request))
        }
        
        public static func inviteCaregiver<T: Decodable>(request: HealthInviteCaregiverRequest) -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.inviteCaregiver(request: request)).eraseToAnyPublisher()
        }
        
        public static func patientList<T: Decodable>() -> AnyPublisher<ListResponseData<T>, APIError> {
            APIService().request(with: Builder.patientList).eraseToAnyPublisher()
        }
        
        public static func perDaySummary<T: Decodable>(request: HealthPerDaySummaryRequest) -> AnyPublisher<ListResponseData<T>, APIError> {
            APIService().request(with: Builder.perDaySummary(request: request)).eraseToAnyPublisher()
        }
        
        public static func records<T: Decodable>(request: HealthRecordsRequest) -> AnyPublisher<ListResponseData<T>, APIError> {
            APIService().request(with: Builder.records(request: request)).eraseToAnyPublisher()
        }
        
        public static func removeCaregiver(request: HealthRemoveCaregiverRequest) -> AnyPublisher<Never, APIError> {
            APIService().request(with: Builder.removeCaregiver(request: request)).eraseToAnyPublisher()
        }
        
        public static func removePatient(request: HealthRemovePatientRequest) -> AnyPublisher<Never, APIError> {
            APIService().request(with: Builder.removePatient(request: request)).eraseToAnyPublisher()
        }
        
        public static func sleepAggregatedRecords<T: Decodable>(request: HealthSleepAggregatedRecordsRequest) -> AnyPublisher<[T], APIError> {
            APIService().request(with: Builder.sleepAggregatedRecords(request: request)).eraseToAnyPublisher()
        }
        
        public static func sleepRecords<T: Decodable>(request: HealthSleepRecordsRequest) -> AnyPublisher<ListResponseData<T>, APIError> {
            APIService().request(with: Builder.sleepRecords(request: request)).eraseToAnyPublisher()
        }
        
        public static func symptoms<T: Decodable>(request: HealthSymptomsRequest) -> AnyPublisher<ListResponseData<T>, APIError> {
            APIService().request(with: Builder.symptoms(request: request)).eraseToAnyPublisher()
        }
        
        public static func userFeelings<T: Decodable>(request: HealthUserFeelingsRequest) -> AnyPublisher<ListResponseData<T>, APIError> {
            APIService().request(with: Builder.userFeelings(request: request)).eraseToAnyPublisher()
        }
        
        public static func userSymptoms<T: Decodable>(request: HealthUserSymptomsRequest) -> AnyPublisher<ListResponseData<T>, APIError> {
            APIService().request(with: Builder.userSymptoms(request: request)).eraseToAnyPublisher()
        }
        
        public static func userSymptomsSummary<T: Decodable>() -> AnyPublisher<[T], APIError> {
            APIService().request(with: Builder.userSymptomsSummary).eraseToAnyPublisher()
        }
    }
}
