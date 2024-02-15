//
//  ScheduleAppointmentViewModel.swift
//  Athelo
//
//  Created by Devsto on 02/02/24.
//

import UIKit
import Combine


protocol ScheduleAppointmentProtocol {
    func scheduleAppointment()
}


final class ScheduleAppointmentViewModel: BaseViewModel{
    
    @Published var allAppointments = Array(repeating: 0, count: 10)
    @Published var providers: ProviderResponselData?
    
    var timeSloats = CurrentValueSubject<ProviderAvability, Never>(ProviderAvability())
    var appointmentBookedResponse = CurrentValueSubject<Bool?, Never>(nil)
    
    
    var isDateSelected = false
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        getProviders()
    }
    
    
    func getProviders(){
        guard state.value != .loading else {
            return
        }
        state.send(.loading)
        
        AtheloAPI.Appointment.getAllProviders()
            .sink { [weak self] complision in
                switch complision {
                case .failure(let err):
                    print("Error is:- ", err.localizedDescription, "***")
                case .finished:
                    print("Provider Called Successfully ***")
                }
                self?.state.send(.loaded)
                
            } receiveValue: { [weak self] responseData in
                self?.providers = responseData
                print(responseData as Any)
            }
            .store(in: &cancellables)
    }
    
    func getTimeSloats(id: Int, date: String){
        guard state.value != .loading else {
            return
        }
        state.send(.loading)
        
        AtheloAPI.Appointment.getProviderAvability(request: .init(id: id , date: date))
            .sink { [weak self] complision in
                self?.state.send(.loaded)
                
                switch complision {
                case .failure(let err):
                    print("Error is ", err.localizedDescription, "***")
                case .finished:                    
                    print("Provider Called Successfully ***")
                }
            } receiveValue: { [weak self] in
                self?.timeSloats.send($0)
                print($0 as Any)
            }
            .store(in: &cancellables)
        
    }
    
    func bookNewAppointment(id: Int, startTime: String){
        guard state.value != .loading else {
            return
        }
        state.send(.loading)
        
        AtheloAPI.Appointment.bookAppointment(request: .init(id: id, starTime: startTime))
            .sink { [weak self] complision in
                
                self?.state.send(.loaded)
                
                switch complision {
                case .failure(let err):
                    print("Error is ", err.localizedDescription, "***")
                    self?.appointmentBookedResponse.send(false)
                case .finished:
                    self?.appointmentBookedResponse.send(true)
                    print("Provider Booked Successfully ***")
                }
                
            }
            .store(in: &cancellables)
    }
    
    func refresh() {
        guard state.value != .loading else {
            return
        }
        getProviders()
    }
}


extension ScheduleAppointmentViewModel {
    enum Messages {
        case bookSuccess
        case bookFail
        case noSlots
        
        var message: String{
            switch self {
            case .bookFail:
                return "message.appointmentSchedule.Fail"
            case .bookSuccess:
                return "message.appointmentSchedule.success"
            case .noSlots:
                return "message.noTimeSloatsAvailabel"
            }
        }
        
        var style: InfoMessageData.MessageType{
            switch self {
                
            case .bookSuccess:
                return .successSecondery
                
            case .bookFail, .noSlots:
                return .fail
            }
        }
        
    }
    
    
    
}
