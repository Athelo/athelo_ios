//
//  JoinAppointmentViewModel.swift
//  Athelo
//
//  Created by Devsto on 14/02/24.
//

import Combine
import UIKit

final class JoinAppointmentViewModel: BaseViewModel {
    
    let kApiKey = "47853731"

    // Replace with your generated session ID
    var kSessionId: String = ""

    // Replace with your generated token
    var kToken = CurrentValueSubject<String, Never>("")

    var kWidgetHeight: Double = 240
    var kWidgetWidth: Double = 320
    
    
    
    
    private var cancellables: [AnyCancellable] = []
    
    
    override init() {
        super.init()
    
    }
    
}

extension JoinAppointmentViewModel {
    
    func getAppointmentDetail(ID id:Int){
        guard state.value != .loading else {
            return
        }
        state.send(.loading)
        
        AtheloAPI.Appointment.getAppointmentDetail(request: .init(id: id))
            .sink { compilation in
                switch compilation{
                case .failure(let error):
                    print(error.localizedDescription)
                case .finished: break
                }
            } receiveValue: {
                self.getVonageDetail(ID: $0.id)
                self.kSessionId = $0.vonageSession ?? ""
            }
            .store(in: &cancellables)
    }
    
    private func getVonageDetail(ID id:Int){
        AtheloAPI.Appointment.getVonageDetail(request: .init(id: id))
            .sink { [weak self] compilation in
                self?.state.send(.loaded)
                
                switch compilation{
                case .failure(let error):
                    print(error.localizedDescription)
                case .finished: break
                }
            } receiveValue: { [weak self] vonage in
                self?.kToken.send(vonage.token)
            }
            .store(in: &cancellables)
    }
    
    
}
