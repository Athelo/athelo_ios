//
//  ScheduleAppointmentViewModel.swift
//  Athelo
//
//  Created by Devsto on 02/02/24.
//

import UIKit
import Combine

final class ScheduleAppointmentViewModel: BaseViewModel{
    
    @Published var allAppointments = Array(repeating: 0, count: 10)
    @Published var providers: ProviderResponselData?

    var timeSloats = CurrentValueSubject<ProviderAvability, Never>(ProviderAvability())
    
        
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
                    print("Error is ", err.localizedDescription, "***")
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
        AtheloAPI.Appointment.getProviderAvability(request: .init(id: id , date: date))
            .sink { complision in
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
    
    func refresh() {
        guard state.value != .loading else {
            return
        }
        getProviders()
    }

}
