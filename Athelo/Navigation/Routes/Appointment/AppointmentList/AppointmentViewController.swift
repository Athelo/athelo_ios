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
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var tableStackHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewBackground: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private var viewModel = AppointmentViewModel()
    private var router: AppointmentRouter?
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
    }
   
    
    // MARK: - Configuration
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
        noAppointmentView.alpha = 1.0
        tableStackHeight.constant = 0
        
    }
    
    private func configureTableView(){
        tableView.register(AppointmentBookedCell.self)
        
        tableView.delegate = self
        tableView.dataSource = self

        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .withStyle(.purple988098)
        
        tableView.refreshControl = refreshControl
        
    }
    
    // MARK: - Sinks
    private func sink(){
        sinkIntoViewModel()
        sinkIntoAppointmentTableView()
    }
    
    private func sinkIntoViewModel(){
        bindToViewModel(viewModel, cancellables: &cancellables)
        
        viewModel.getAllAppointmnets()
        
        viewModel.$allAppointments
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.tableView.reloadData()
                let ishide = data.count>0
                self?.noAppointmentView.alpha = ishide ? 0.0 : 1.0
                self?.tableStackHeight.constant = ishide ? (self?.stackView.frame.height ?? 0) - 52 - 16 : 0
                
            }.store(in: &cancellables)
        
        viewModel.state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                switch $0 {
                case .error, .loaded:
                    self?.tableView.refreshControl?.endRefreshing()
                case .loading, .initial:
                    break
                }
            }.store(in: &cancellables)
        
    }
    
    private func sinkIntoAppointmentTableView() {
        tableView.refreshControl?.controlEventPublisher(for: .valueChanged)
            .sinkDiscardingValue { [weak self] in
                if self?.viewModel.state.value == .loading {
                    self?.tableView.refreshControl?.endRefreshing()
                } else {
                    self?.viewModel.refresh()
                }
            }.store(in: &cancellables)
    }
    
    // MARK: - Actions
    @IBAction func onClickScheduleAppointmentBtn(_ sender: UIButton) {
        routToReschedualVC()
    }
}

// MARK: - Protocol conformance
// MARK: UITableViewDataSource
extension AppointmentViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.allAppointments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: AppointmentBookedCell.self, for: indexPath)
        cell.configure(.init(viewModel.allAppointments[indexPath.row]), indexPath: indexPath)
        cell.parentScreen = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        150
    }
}

extension AppointmentViewController: PopoverActions {
    func PopoverActions(Action type: PopoverView.ResponseType, On index: Int) {
        switch type {
        case .delete:
            viewModel.deleteAppointment(AppointmentID: viewModel.allAppointments[index].id)
            viewModel.allAppointments.remove(at: index)
            displayMessage("message.appointmentRemove.success".localized(), type: .successSecondery)
            
        case .join:
            router?.navigatetoJoinAppointment(onId: viewModel.allAppointments[index].id)
            
        case .reschedule:
            routToReschedualVC()
        }
    }
    
}

// MARK: Routable
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

extension AppointmentViewController {
    func routToReschedualVC(){
        router?.navigatetoScheduleAppointment(delegate: viewModel)
    }
}
