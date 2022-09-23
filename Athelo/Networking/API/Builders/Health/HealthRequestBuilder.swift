//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 14/07/2022.
//

import Foundation

enum HealthRequestBuilder: APIBuilderProtocol {
    case activityDashboard(request: HealthActivityDashboardRequest)
    case addUserFeeling(request: HealthAddFeelingRequest)
    case addUserSymptom(request: HealthAddSymptomRequest)
    case caregiverList
    case createSymptom(request: HealthCreateSymptomRequest)
    case dashboard(request: HealthDashboardRequest)
    case deleteSymptom(request: HealthDeleteSymptomRequest)
    case patientList
    case perDaySummary(request: HealthPerDaySummaryRequest)
    case records(request: HealthRecordsRequest)
    case sleepAggregatedRecords(request: HealthSleepAggregatedRecordsRequest)
    case sleepRecords(request: HealthSleepRecordsRequest)
    case symptoms(request: HealthSymptomsRequest)
    case userFeelings(request: HealthUserFeelingsRequest)
    case userSymptoms(request: HealthUserSymptomsRequest)
    case userSymptomsSummary
    
    var headers: [String : String]? {
        switch self {
        case .activityDashboard, .addUserFeeling, .addUserSymptom, .caregiverList, .createSymptom, .dashboard, .deleteSymptom, .patientList, .perDaySummary, .records, .sleepAggregatedRecords, .sleepRecords, .symptoms, .userFeelings, .userSymptoms, .userSymptomsSummary:
            return nil
        }
    }
    
    var method: APIMethod {
        switch self {
        case .activityDashboard, .addUserFeeling, .addUserSymptom, .createSymptom, .dashboard, .sleepAggregatedRecords:
            return .post
        case .deleteSymptom:
            return .delete
        case .caregiverList, .patientList, .perDaySummary, .records, .sleepRecords, .symptoms, .userFeelings, .userSymptoms, .userSymptomsSummary:
            return .get
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .activityDashboard(let request as APIRequest),
                .addUserFeeling(let request as APIRequest),
                .addUserSymptom(let request as APIRequest),
                .createSymptom(let request as APIRequest),
                .dashboard(let request as APIRequest),
                .deleteSymptom(let request as APIRequest),
                .perDaySummary(let request as APIRequest),
                .records(let request as APIRequest),
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
        case .activityDashboard(let request):
            var path = "/health/activity/generate-dashboard/"
            
            let queryItems: [URLQueryItem] = [
                .init(name: "start_date", value: request.startDate.toString(.custom("yyyy-MM-dd"))),
                .init(name: "end_date", value: request.endDate.toString(.custom("yyyy-MM-dd")))
            ]
            
            path += queryItems.intoQuery()
            
            return path
        case .addUserFeeling:
            return "/health/user_feeling/"
        case .addUserSymptom:
            return "/health/user_symptoms/"
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
            
            if !queryItems.isEmpty {
                path += queryItems.intoQuery()
            }
            
            return path
        case .deleteSymptom(let request):
            return "/health/user_symptoms/\(request.symptomID)/"
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
            
            if !queryItems.isEmpty {
                path += queryItems.intoQuery()
            }
            
            return path
        case .sleepAggregatedRecords(let request):
            var path = "/health/sleep_record/\(request.dataGranularity.path)/"
            
            var queryItems: [URLQueryItem] = []
            
            if let dates = request.dates?.toQueryItems(for: "collected_at_date", format: "yyyy-MM-dd"), !dates.isEmpty {
                queryItems.append(contentsOf: dates)
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
