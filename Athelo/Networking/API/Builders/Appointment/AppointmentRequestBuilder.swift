//
//  AppointmentRequestBuilder.swift
//  Athelo
//
//  Created by Devsto on 05/02/24.
//

import Foundation

enum AppointmentRequestBuilder: APIBuilderProtocol{
    case providers
    case providerAvability(request: ProviderAvabilityRequest)
    case bookAppointment(request: BookAppoointmentRequest)
    case getAppointments
    case delete(request: DeleteAppointmentRequest)
    case appointmentDetail(request: JoinAppointmentRequest)
    case vonageKey(request: JoinAppointmentRequest)
    
    var headers: [String : String]? {
        switch self {
        case .providers, .providerAvability, .bookAppointment, .getAppointments, .delete, .appointmentDetail, .vonageKey:
            return nil
        }
    }
    
    var method: APIMethod {
        switch self {
        case .providers, .getAppointments, .providerAvability, .appointmentDetail, .vonageKey:
            return .get
            
        case .delete:
            return .delete
            
        case .bookAppointment:
            return .post
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .bookAppointment(let request as APIRequest):
            return request.parameters
            
        case .providers, .getAppointments, .appointmentDetail, .providerAvability, .delete, .vonageKey:
            return nil
        }
    }
    
    var path: String {
        switch self {
        case .providers:
            return "/providers"
            
        case .providerAvability(request: let request):
            return "/providers/\(request.id)/availability/?date=\(request.date)&tz=\(request.timeZone)"
            
        case .bookAppointment( _ as APIRequest):
            return "/appointments/"
            
        case .getAppointments:
            return "/appointments/"
            
        case .delete(request: let request):
            return "/appointment/\(request.id)/"
            
        case .appointmentDetail(request: let request):
            return "/appointment/\(request.id)/"
            
        case .vonageKey(request: let request):
            return "/appointment/\(request.id)/vonage-appointment-details/"
        }
        
    
    }
    
    
}
