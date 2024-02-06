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

}
