//
//  ScheduleAppointmentViewController.swift
//  Athelo
//
//  Created by Devsto on 30/01/24.
//

import UIKit
import Combine

final class ScheduleAppointmentViewController: BaseViewController{
    
    // MARK: - Properties
    
    private var router: ScheduleAppointmentRouter?
    private var cancellables: [AnyCancellable] = []
    
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    
    private func configure() {
        configureOwnView()
    }
    
    private func configureOwnView() {
        navigationItem.title = "navigation.scheduleAppointment".localized()
    }
    
    
    
    
    
    
}

extension ScheduleAppointmentViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .appointment
    }
}

// MARK: Routable
extension ScheduleAppointmentViewController: Routable {
    func assignRouter(_ router: ScheduleAppointmentRouter) {
        self.router = router
    }
}
