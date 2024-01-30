//
//  AppointmentViewController.swift
//  Athelo
//
//  Created by Devsto on 30/01/24.
//

import UIKit
import Combine


final class AppointmentViewController: BaseViewController{
   
    // MARK: - Outlets
    
    @IBOutlet weak var schesualAppointmentBtn: StyledButton!
    @IBOutlet weak var noAppointmentView: NoAppointment!
    
    // MARK: - Properties
    private var router: AppointmentRouter?

    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    private func configure() {
        configureNoAppoitmentView()
        configureOwnView()
    }
    
    
    private func configureOwnView() {
        navigationItem.displayAppLogo()
        
        cancellables.append(navigationItem.displayUserAvatar(with: router))
    }
    private func configureNoAppoitmentView() {
        noAppointmentView.alpha = 0.0
        
    }
    
    @IBAction func onClickScheduleAppointmentBtn(_ sender: UIButton) {
        router?.navigatetoScheduleAppointment()
        
    }
    
}





extension AppointmentViewController: Routable {
    func assignRouter(_ router: AppointmentRouter) {
        self.router = router
    }
}

// MARK: Navigable
extension AppointmentViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .appointment
    }
}
