//
//  AppointmentViewController.swift
//  Athelo
//
//  Created by Devsto on 30/01/24.
//

import UIKit
import Combine


final class AppointmentViewController: BaseViewController, UITableViewDelegate{
   
    
   
    // MARK: - Outlets
    
    @IBOutlet weak var schesualAppointmentBtn: StyledButton!
    @IBOutlet weak var noAppointmentView: NoAppointment!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var tableStackHeight: NSLayoutConstraint!
    @IBOutlet weak var hideView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var ishide = false
    
    
    
    // MARK: - Properties
    private var viewModel: AppointmentViewModel?
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
        configureTableView()
    }
    
    
    private func configureOwnView() {
        navigationItem.displayAppLogo()
        
        cancellables.append(navigationItem.displayUserAvatar(with: router))
    }
    
    private func configureNoAppoitmentView() {
        noAppointmentView.alpha = 0.0
        
    }
    
    private func configureTableView(){
        tableView.register(AppointmentBookedCell.self)
        
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    
    @IBAction func onClickScheduleAppointmentBtn(_ sender: UIButton) {
        router?.navigatetoScheduleAppointment()
        
        //Button manage
//        noAppointmentView.alpha = ishide ? 1.0 : 0.0
//        hideView.isHidden = !ishide
//        tableStackHeight.constant = ishide ? 0 : stackView.frame.height - 52 - 16
//        ishide.toggle()
    }
}

// MARK: - Protocol conformance
// MARK: UITableViewDataSource
extension AppointmentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.allAppointments.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: AppointmentBookedCell.self, for: indexPath)
        cell.backgroundColor = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        150
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
