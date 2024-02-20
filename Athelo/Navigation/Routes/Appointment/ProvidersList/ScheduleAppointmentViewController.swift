//
//  ScheduleAppointmentViewController.swift
//  Athelo
//
//  Created by Devsto on 30/01/24.
//

import UIKit
import Combine

final class ScheduleAppointmentViewController: BaseViewController, UITableViewDelegate{

    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private var router: ScheduleAppointmentRouter?
    private var cancellables: [AnyCancellable] = []
    private var expandedCellIndex: IndexPath?
    private var selectedDate: String? = nil
    private var viewModel = ScheduleAppointmentViewModel()
    
    var delegate: ScheduleAppointmentProtocol?
    
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureOwnView()
        configureTableView()
    }
  
    
    private func configureOwnView() {
        navigationItem.title = "navigation.scheduleAppointment".localized()
    }
    
    private func configureTableView() {
        tableView.register(ScheduleAppointmentCell.self)
        
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
        
        viewModel.$providers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.timeSloats
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                if self?.selectedDate != nil {
                    if $0.times.count == 0 {
                        self?.showMessge(.noSlots)
                    }else{
                        self?.tableView.reloadRows(at: [self?.expandedCellIndex ?? IndexPath(item: 0, section: 0)], with: .fade)
                        self?.tableView.reloadData()
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
                            self?.tableView.reloadData()
                            self?.tableView.reloadRows(at: [self?.expandedCellIndex ?? IndexPath(item: 0, section: 0)], with: .fade)
                            
                            
                        }
                    }
                }
            }
            .store(in: &cancellables)
        
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
        
        viewModel.appointmentBookedResponse
            .sink { isSuccess in
                if isSuccess != nil {
                    if isSuccess! {
                        DispatchQueue.main.async{
                            self.router?.navigationController?.popViewController(animated: true)
                            self.showMessge(.bookSuccess)
                            self.delegate?.scheduleAppointment()
                        }
                    }else{
                        self.showMessge(.bookFail)
                    }
                }
            }
            .store(in: &cancellables)
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

    
}

// MARK: - Protocol conformance
// MARK: UITableViewDataSource
extension ScheduleAppointmentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.providers?.results.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ScheduleAppointmentCell.self, for: indexPath)
        
        let schedualeCellData = ScheduleCellDecoration(providerDetail: viewModel.providers!.results[indexPath.row], state: expandedCellIndex == indexPath ? .expanded : .noramal)
        cell.configure(schedualeCellData, indexPath: indexPath)
        cell.appointmentSchedulingView.reloadCell = reloadRow
        cell.appointmentSchedulingView.schedualAction = appointmentBooked
        cell.timeSloats = viewModel.timeSloats.value
        cell.selectedDate = selectedDate ?? ""
        if expandedCellIndex == indexPath{
            let isCalanderHide = viewModel.timeSloats.value.times.count > 0
            cell.appointmentSchedulingView.dateBackgroundView.isHidden = isCalanderHide
            cell.appointmentSchedulingView.timeSlotView.isHidden = !(isCalanderHide)
            if selectedDate == nil{
                 cell.appointmentSchedulingView.dateBackgroundView.isHidden = false
                 cell.appointmentSchedulingView.timeSlotView.isHidden = true
            }
        }
        cell.appointmentSchedulingView.collectionView.reloadData()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let temp = expandedCellIndex
        expandedCellIndex = expandedCellIndex==indexPath ? nil : indexPath
        if temp != indexPath{
            selectedDate = nil
            viewModel.timeSloats.send(ProviderAvability())
        }
        tableView.reloadRows(at: [indexPath, temp ?? indexPath], with: .fade)
    }
    
    func reloadRow(isTimePickerDate: String?){
        selectedDate = isTimePickerDate
        if isTimePickerDate != nil{
            viewModel.getTimeSloats(id: viewModel.providers!.results[expandedCellIndex?.row ?? 0].id, date: selectedDate!)
        }else{
            viewModel.timeSloats.send(ProviderAvability())
            tableView.reloadData()
        }
    }
}

// MARK: Methods
extension ScheduleAppointmentViewController{
    func appointmentBooked(time: String){
        if selectedDate != nil{
            let date = selectedDate?.changeDateStringTo(Base: .MM_dd_yyyy, Changeto: .yyyy_MM_dd)
            let strTime = time.changeDateStringTo(Base: .hh_mm_a, Changeto: .HH_mm_ss)
            viewModel.bookNewAppointment(id: viewModel.providers!.results[expandedCellIndex?.row ?? 0].id, startTime: "\(date!)T\(strTime!)")
        }
    }
    
    func showMessge(_ message: ScheduleAppointmentViewModel.Messages) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
            
            self.displayMessage(message.message.localized(), type: message.style)
            
        }
    }
}

// MARK: Navigatable
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
