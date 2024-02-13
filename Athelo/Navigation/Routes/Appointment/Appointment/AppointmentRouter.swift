//
//  AppointmentRouter.swift
//  Athelo
//
//  Created by Devsto on 30/01/24.
//

import Foundation
import UIKit
import Combine

final class AppointmentRouter: Router, UserProfileRoutable{
    // MARK: - Properties
    weak var navigationController: UINavigationController?
    let appointmentSubject: AppointmentSubject
    
    // MARK: - Initialization
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.appointmentSubject = AppointmentSubject()
    }
    
    init(navigationController: UINavigationController, appointmentSubject: AppointmentSubject?) {
        self.navigationController = navigationController
        self.appointmentSubject = appointmentSubject ?? AppointmentSubject()
    }
    
    @MainActor func navigatetoScheduleAppointment(){
        guard let navigationController = navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        
        let router = ScheduleAppointmentRouter(navigationController: navigationController)
        let viewController = ScheduleAppointmentViewController.viewController(router: router)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
}

// MARK: - Helper extensions
extension AppointmentRouter {
    typealias AppointmentSubject = PassthroughSubject<UpdateEvent, Never>
    
    enum UpdateEvent {
        
    }
}
