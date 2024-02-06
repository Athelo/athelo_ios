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
    private var isDateSelect = false
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
        
    }
    
    private func sinkIntoViewModel(){
        bindToViewModel(viewModel, cancellables: &cancellables)
        
    }
    
}

// MARK: - Protocol conformance
// MARK: UITableViewDataSource
extension ScheduleAppointmentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.allAppointments.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ScheduleAppointmentCell.self, for: indexPath)
        cell.configure(expandedCellIndex == indexPath ? .expanded : .noramal, isTimesloatHide: !isDateSelect, indexPath: indexPath)
        cell.appointmentSchedulingView.reloadCell = reloadRow
        cell.appointmentSchedulingView.schedualAction = appointmentBooked
        if expandedCellIndex == indexPath{
            cell.appointmentSchedulingView.timeSlotView.isHidden = !isDateSelect
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let temp = expandedCellIndex
        expandedCellIndex = expandedCellIndex==indexPath ? nil : indexPath
        if temp != indexPath{
            isDateSelect = false
        }
        tableView.reloadRows(at: [indexPath, temp ?? indexPath], with: .fade)
    }
    
    func reloadRow(isTimePicker: Bool){
        isDateSelect = isTimePicker
        tableView.reloadRows(at: [expandedCellIndex ?? IndexPath(row: 0, section: 0)], with: .automatic)
    }
    
}

extension ScheduleAppointmentViewController{
    func appointmentBooked(){
        print(expandedCellIndex!.row, "Row Appointed")
        router?.navigationController?.popViewController(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.7) {
            self.displayMessage("message.appointmentSchedule.success".localized(), type: .successSecondery)
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
