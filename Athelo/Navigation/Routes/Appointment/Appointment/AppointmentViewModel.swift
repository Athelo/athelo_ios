//
//  AppointmentViewModel.swift
//  Athelo
//
//  Created by Devsto on 30/01/24.
//

import Combine
import UIKit

final class AppointmentViewModel: BaseViewModel{
    
//    @Published var allAppointments = CurrentValueSubject<AppointmentResponse, Never>(AppointmentResponse(from: <#Decoder#>)
    
    private var cancellables: [AnyCancellable] = []
    override init() {
        super.init()
        
//        getAllProviders()
//        print(allAppointments.sink(receiveValue: { data in
//            print(data,"**")
//        }))
    }
    
    
    
    
    func getAllProviders() {
            
        

        
    }
}
