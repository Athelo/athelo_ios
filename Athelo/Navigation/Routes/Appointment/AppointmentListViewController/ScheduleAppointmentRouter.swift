//
//  ScheduleAppointmentRouter.swift
//  Athelo
//
//  Created by Devsto on 30/01/24.
//

import Foundation
import UIKit
import Combine


final class ScheduleAppointmentRouter: Router{
    // MARK: - Properties
    weak var navigationController: UINavigationController?
    let appointmentSubject: ScheduleAppointmentSubject
    
    // MARK: - Initialization
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.appointmentSubject = ScheduleAppointmentSubject()
    }
    
    init(navigationController: UINavigationController, appointmentSubject: ScheduleAppointmentSubject?) {
        self.navigationController = navigationController
        self.appointmentSubject = appointmentSubject ?? ScheduleAppointmentSubject()
    }
}

// MARK: - Helper extensions
extension ScheduleAppointmentRouter {
    typealias ScheduleAppointmentSubject = PassthroughSubject<UpdateEvent, Never>
    
    enum UpdateEvent {
        
    }
}
