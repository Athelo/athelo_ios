//
//  AppointmentViewModel.swift
//  Athelo
//
//  Created by Devsto on 30/01/24.
//

import Combine
import UIKit

final class AppointmentViewModel: BaseViewModel{
    
    @Published var allAppointments: [AppointmetntData] = []
    
    private var cancellables: [AnyCancellable] = []
    
    override init() {
        super.init()
    
    }
    
    func getAllAppointmnets() {
        guard state.value != .loading else {
            return
        }
        state.send(.loading)
        
        AtheloAPI.Appointment.getAllAppointments()
            .sink { [weak self] compilation in
                self?.state.send(.loaded)
                
                switch compilation{
                case .failure(let error):
                    print(error.localizedDescription)
                case .finished: break
                }
            } receiveValue: { [weak self] in
                self?.allAppointments = $0.results
            }
            .store(in: &cancellables)
        
    }
    
    func deleteAppointment(AppointmentID id:Int){
        AtheloAPI.Appointment.delete(request: .init(id: id))
            .sink { compilation in
                switch compilation{
                case .failure(let error):
                    print(error.localizedDescription)
                case .finished: return
                }
            }
            .store(in: &cancellables)
    }
    
    func refresh() {
        guard state.value != .loading else {
            return
        }
        getAllAppointmnets()
    }
    
}


extension AppointmentViewModel: ScheduleAppointmentProtocol {
    func scheduleAppointment() {
        refresh()
    }
}
