//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 14/07/2022.
//

import Foundation

enum HealthRequestBuilder: APIBuilderProtocol {
    case acceptCaregiverInvitation(request: HealthAcceptCaregiverInvitationRequest)
    case activityDashboard(request: HealthActivityDashboardRequest)
    case addUserFeeling(request: HealthAddFeelingRequest)
    case addUserSymptom(request: HealthAddSymptomRequest)
    case cancelInvitation(request: HealthCancelInvitationRequest)
    case caregiverList
    case createSymptom(request: HealthCreateSymptomRequest)
    case dashboard(request: HealthDashboardRequest)
    case deleteSymptom(request: HealthDeleteSymptomRequest)
    case invitations(request: HealthInvitationsRequest)
    case inviteCaregiver(request: HealthInviteCaregiverRequest)
    case patientList
    case perDaySummary(request: HealthPerDaySummaryRequest)
    case records(request: HealthRecordsRequest)
    case removeCaregiver(request: HealthRemoveCaregiverRequest)
    case removePatient(request: HealthRemovePatientRequest)
    case sleepAggregatedRecords(request: HealthSleepAggregatedRecordsRequest)
    case sleepRecords(request: HealthSleepRecordsRequest)
    case symptoms(request: HealthSymptomsRequest)
    case userFeelings(request: HealthUserFeelingsRequest)
    case userSymptoms(request: HealthUserSymptomsRequest)
    case userSymptomsSummary
    
    var headers: [String : String]? {
        return nil
    }
    
    var method: APIMethod {
        switch self {
        case .acceptCaregiverInvitation, .activityDashboard, .addUserFeeling, .addUserSymptom, .cancelInvitation, .createSymptom, .dashboard, .inviteCaregiver, .sleepAggregatedRecords:
            return .post
        case .deleteSymptom, .removeCaregiver, .removePatient:
            return .delete
        case .caregiverList, .invitations, .patientList, .perDaySummary, .records, .sleepRecords, .symptoms, .userFeelings, .userSymptoms, .userSymptomsSummary:
            return .get
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .acceptCaregiverInvitation(let request as APIRequest),
                .activityDashboard(let request as APIRequest),
                .addUserFeeling(let request as APIRequest),
                .addUserSymptom(let request as APIRequest),
                .cancelInvitation(let request as APIRequest),
                .createSymptom(let request as APIRequest),
                .dashboard(let request as APIRequest),
                .deleteSymptom(let request as APIRequest),
                .invitations(let request as APIRequest),
                .inviteCaregiver(let request as APIRequest),
                .perDaySummary(let request as APIRequest),
                .records(let request as APIRequest),
                .removeCaregiver(let request as APIRequest),
                .removePatient(let request as APIRequest),
                .sleepAggregatedRecords(let request as APIRequest),
                .sleepRecords(let request as APIRequest),
                .symptoms(let request as APIRequest),
                .userFeelings(let request as APIRequest),
                .userSymptoms(let request as APIRequest):
            return request.parameters
        case .caregiverList,
                .patientList,
                .userSymptomsSummary:
            return nil
        }
    }
    
    var path: String {
        switch self {
        case .acceptCaregiverInvitation(let request):
            return "/health/caregiver_invitations/consume/\(request.invitationCode)/"
        case .activityDashboard(let request):
            var path = "/health/activity/generate-dashboard/"
            
            var queryItems: [URLQueryItem] = [
                .init(name: "start_date", value: request.startDate.toString(.custom("yyyy-MM-dd"))),
                .init(name: "end_date", value: request.endDate.toString(.custom("yyyy-MM-dd")))
            ]
            
            if let patientID = request.patientID, patientID > 0 {
                queryItems.append(.init(name: "_patient_id", value: "\(patientID)"))
            }
            
            path += queryItems.intoQuery()
            
            return path
        case .addUserFeeling:
            return "/health/user_feeling/"
        case .addUserSymptom:
            return "/health/user_symptoms/"
        case .cancelInvitation(let request):
            return "/health/caregiver_invitations/\(request.invitationID)/cancel/"
        case .caregiverList:
            return "/health/caregivers/"
        case .createSymptom:
            return "/health/symptoms/"
        case .dashboard(let request):
            var path = "/health/\(request.dataType.path)/generate-dashboard/"
            
            var queryItems: [URLQueryItem] = []
            
            if let dates = request.dates?.toQueryItems(for: "collected_at_date", format: "yyyy-MM-dd"), !dates.isEmpty {
                queryItems.append(contentsOf: dates)
            }
            
            if let patientID = request.patientID, patientID > 0 {
                queryItems.append(.init(name: "_patient_id", value: "\(patientID)"))
            }
            
            if !queryItems.isEmpty {
                path += queryItems.intoQuery()
            }
            
            return path
        case .deleteSymptom(let request):
            return "/health/user_symptoms/\(request.symptomID)/"
        case .invitations(let request):
            var path = "/health/caregiver_invitations/"
            
            var queryItems: [URLQueryItem] = []
            
            if let invitationIDs = request.invitationIDs, !invitationIDs.isEmpty {
                queryItems.append(.init(name: "id__in", value: invitationIDs.map({ "\($0)" }).joined(separator: ",")))
            }
            
            if let statuses = request.statuses, !statuses.isEmpty {
                queryItems.append(URLQueryItem(name: "status__in", value: statuses.map({ $0.parameterName }).joined(separator: ",")))
            }
            
            if !queryItems.isEmpty {
                path += queryItems.intoQuery()
            }
            
            return path
        case .inviteCaregiver:
            return "/health/caregiver_invitations/invite/"
        case .patientList:
            return "/health/patients/"
        case .perDaySummary(let request):
            var path = "/health/user_feelings_and_symptoms_per_day/"
            
            var queryItems: [URLQueryItem] = []
            
            if let grouping = request.grouping {
                switch grouping {
                case .byFeelings:
                    queryItems.append(.init(name: "by_feelings", value: "true"))
                case .bySymptoms:
                    queryItems.append(.init(name: "by_symptoms", value: "true"))
                }
            }
            
            if !queryItems.isEmpty {
                path += queryItems.intoQuery()
            }
            
            return path
        case .records(let request):
            var path = "/health/\(request.dataType.path)/"
            
            var queryItems: [URLQueryItem] = []
            
            if let dates = request.dates?.toQueryItems(for: "collected_at_date", format: "yyyy-MM-dd"), !dates.isEmpty {
                queryItems.append(contentsOf: dates)
            }
            
            if let pageSize = request.pageSize, pageSize > 0 {
                queryItems.append(.init(name: "page_size", value: "\(pageSize)"))
            }
            
            if let patientID = request.patientID, patientID > 0 {
                queryItems.append(.init(name: "_patient_id", value: "\(patientID)"))
            }
            
            if !queryItems.isEmpty {
                path += queryItems.intoQuery()
            }
            
            return path
        case .removeCaregiver(let request):
            return "/health/caregivers/\(request.caregiverID)/"
        case .removePatient(let request):
            return "/health/patients/\(request.patientID)/"
        case .sleepAggregatedRecords(let request):
            var path = "/health/sleep_record/\(request.dataGranularity.path)/"
            
            var queryItems: [URLQueryItem] = []
            
            if let dates = request.dates?.toQueryItems(for: "collected_at_date", format: "yyyy-MM-dd"), !dates.isEmpty {
                queryItems.append(contentsOf: dates)
            }
            
            if let patientID = request.patientID, patientID > 0 {
                queryItems.append(.init(name: "_patient_id", value: "\(patientID)"))
            }
            
            if !queryItems.isEmpty {
                path += queryItems.intoQuery()
            }
            
            return path
        case .sleepRecords(let request):
            var path = "/health/sleep_record/"
            
            var queryItems: [URLQueryItem] = []
            
            if let dates = request.dates?.toQueryItems(for: "collected_at_date", format: "yyyy-MM-dd"), !dates.isEmpty {
                queryItems.append(contentsOf: dates)
            }
            
            if let exactMonth = request.exactMonth {
                queryItems.append(.init(name: "collected_at_date__month", value: "\(exactMonth)"))
            }
            
            if let exactYear = request.exactYear {
                queryItems.append(.init(name: "collected_at_date__year", value: "\(exactYear)"))
            }
            
            if let patientID = request.patientID, patientID > 0 {
                queryItems.append(.init(name: "_patient_id", value: "\(patientID)"))
            }
            
            if !queryItems.isEmpty {
                path += queryItems.intoQuery()
            }
            
            return path
        case .symptoms(let request):
            var path = "/health/symptoms/"
            
            var queryItems: [URLQueryItem] = []
            
            if let query = request.query, !query.isEmpty {
                queryItems.append(.init(name: "name__icontains", value: query))
            }
            
            if let symptomIDs = request.symptomIDs, !symptomIDs.isEmpty {
                queryItems.append(.init(name: "id__in", value: symptomIDs.map({ "\($0)" }).joined(separator: ",")))
            }
            
            if !queryItems.isEmpty {
                path += queryItems.intoQuery()
            }
            
            return path
        case .userFeelings(let request):
            var path = "/health/user_feeling/"
            
            var queryItems: [URLQueryItem] = []
            
            if let occurrenceDates = request.occurrenceDates?.toQueryItems(for: "occurrence_date", format: "yyyy-MM-dd"), !occurrenceDates.isEmpty {
                queryItems.append(contentsOf: occurrenceDates)
            }
            
            if !queryItems.isEmpty {
                path += queryItems.intoQuery()
            }
            
            return path
        case .userSymptoms(let request):
            var path = "/health/user_symptoms/"
            
            var queryItems: [URLQueryItem] = []
            
            if let occurrenceDates = request.occurrenceDates?.toQueryItems(for: "occurrence_date", format: "yyyy-MM-dd"), !occurrenceDates.isEmpty {
                queryItems.append(contentsOf: occurrenceDates)
            }
            
            if let symptomIDs = request.symptomIDs, !symptomIDs.isEmpty {
                queryItems.append(.init(name: "symptom__id__in", value: symptomIDs.map({ "\($0)" }).joined(separator: ",")))
            }
            
            if !queryItems.isEmpty {
                path += queryItems.intoQuery()
            }
            
            return path
        case .userSymptomsSummary:
            return "/health/user_symptoms/summary/"
        }
    }
}

private extension HealthDashboardParameters.DataType {
    var path: String {
        switch self {
        case .calories:
            return "calories_record"
        case .heartRate:
            return "heart_rate_record"
        case .hrv:
            return "heart_rate_variability_record"
        case .sleep:
            return "sleep_record"
        case .steps:
            return "steps_record"
        }
    }
}

private extension HealthSleepAggregatedRecordsRequest.DataGranularity {
    var path: String {
        switch self {
        case .all:
            return "generate-dashboard"
        case .byPhase:
            return "generate-level-aggregation-dashboard"
        }
    }
}
