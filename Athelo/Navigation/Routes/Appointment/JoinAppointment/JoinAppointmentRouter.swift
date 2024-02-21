//
//  JoinAppointmentRouter.swift
//  Athelo
//
//  Created by Devsto on 13/02/24.
//

import Foundation
import UIKit
import Combine



final class JoineAppointmentRouter: Router{
    // MARK: - Properties
    weak var navigationController: UINavigationController?
    let appointmentSubject: JoineAppointmentSubject
    
    // MARK: - Initialization
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.appointmentSubject = JoineAppointmentSubject()
    }
    
    init(navigationController: UINavigationController, appointmentSubject: JoineAppointmentSubject?) {
        self.navigationController = navigationController
        self.appointmentSubject = appointmentSubject ?? JoineAppointmentSubject()
    }
    
}


// MARK: - Helper extensions
extension JoineAppointmentRouter {
    typealias JoineAppointmentSubject = PassthroughSubject<UpdateEvent, Never>
    
    enum UpdateEvent {
        
    }
}
