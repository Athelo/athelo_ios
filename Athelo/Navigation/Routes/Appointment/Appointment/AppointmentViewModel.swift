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
    var isLastDeleteAction = false
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
                    print("** Error:- ",error.localizedDescription)
                case .finished:
                    print("Appointment Data get Successfully")
                }
            } receiveValue: { [weak self] in
                self?.allAppointments = $0.results
            }
            .store(in: &cancellables)
        
    }
    
    func deleteAppointment(AppointmentID id:Int){
        guard state.value != .loading else {
            return
        }
        state.send(.loading)
        
        AtheloAPI.Appointment.delete(request: .init(id: id))
            .sink { [weak self] compilation in
                self?.state.send(.loaded)
                switch compilation{
                case .failure(let error):
                    print("** Error:- ",error.localizedDescription)
                case .finished:
                    print("Appointment Deleted Successfully")
                    self?.refresh()
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
