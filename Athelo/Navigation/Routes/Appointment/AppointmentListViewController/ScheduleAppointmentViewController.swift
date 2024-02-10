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
    
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
    }
    
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
    }
    
    // MARK: - Sinks
    private func sink(){
        sinkIntoViewModel()
        sinkIntoProvidersTableView()
        viewModel.bookingResponse = bookingResponse
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
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                            self?.displayMessage("message.noTimeSloatsAvailabel".localized(), type: .successSecondery)
                        }
                    }
                }
                self?.viewModel.isDateSelected = $0.times.count<0
                self?.tableView.reloadData()
                self?.tableView.reloadRows(at: [self?.expandedCellIndex ?? IndexPath(row: 0, section: 0)], with: .fade)
            }
            .store(in: &cancellables)
    }
    
    private func sinkIntoProvidersTableView() {
        tableView.refreshControl?.controlEventPublisher(for: .valueChanged)
            .sinkDiscardingValue { [weak self] in
                if self?.viewModel.state.value == .loading {
                    self?.tableView.refreshControl?.endRefreshing()
                } else {
                    self?.viewModel.refresh()
                }
            }.store(in: &cancellables)
    }
    

    func bookingResponse(isSuccess: Bool){
        if isSuccess {
            DispatchQueue.main.async{
                self.router?.navigationController?.popViewController(animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
                    self.displayMessage("message.appointmentSchedule.success".localized(), type: .successSecondery)
                }
            }
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
                self.displayMessage("message.appointmentSchedule.success".localized(), type: .successSecondery)
            }
        }
        
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
        cell.appointmentSchedulingView.selectedDateLbl.text = selectedDate?.changeDateStringTo(Base: "MM/dd/yyyy", Changeto: "dd MMM, EEEE") ?? "No Selected"
        if expandedCellIndex == indexPath{
            let isCalanderHide = viewModel.timeSloats.value.times.count > 0
            cell.appointmentSchedulingView.dateBackgroundView.isHidden = isCalanderHide
            cell.appointmentSchedulingView.timeSlotView.isHidden = !(isCalanderHide)
            cell.appointmentSchedulingView.selectedDateLbl.text = selectedDate
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
            viewModel.isDateSelected = false
        }
        tableView.reloadRows(at: [indexPath, temp ?? indexPath], with: .fade)
    }
    
    func reloadRow(isTimePickerDate: String?){
        selectedDate = isTimePickerDate
        if isTimePickerDate != nil{
            viewModel.getTimeSloats(id: viewModel.providers!.results[expandedCellIndex?.row ?? 0].id, date: selectedDate!)
        }
    }
    
}

extension ScheduleAppointmentViewController{
    func appointmentBooked(time: String){
        if selectedDate != nil{
            let date = selectedDate?.changeDateStringTo(Base: "MM/dd/yyyy", Changeto: "yyyy-MM-dd")
            let strTime = time.changeDateStringTo(Base: "hh:mm a", Changeto: "HH:mm:ss")
            viewModel.bookNewAppointment(id: viewModel.providers!.results[expandedCellIndex?.row ?? 0].id, startTime: "\(date!)T\(strTime!)")
        }
        
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
