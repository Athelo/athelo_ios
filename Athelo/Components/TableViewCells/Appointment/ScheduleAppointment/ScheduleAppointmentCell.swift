//
//  ScheduleAppointmentCell.swift
//  Athelo
//
//  Created by Devsto on 31/01/24.
//
import UIKit


final class ScheduleAppointmentCell: UITableViewCell{
    
    // MARK: - Outlets
    @IBOutlet weak var professionLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var arrowImg: UIImageView!
    @IBOutlet weak var appointmentSchedulingView: AppointmnetCalanderView!
    
    // MARK: - Properties
    var selectedTimeCell: IndexPath? = nil
    
    
    // MARK: - View lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    // MARK: - Funcitons
    // MARK: Configration
    private func configure() {
        configureOwnView()
        configureAppointmentCalanderView()
    }
    
    private func configureOwnView() {
        selectionStyle = .none
        backgroundColor = .none
        
    }
    
    private func configureAppointmentCalanderView() {
        appointmentSchedulingView.selectedDateView.layer.borderColor = #colorLiteral(red: 0.4078431373, green: 0.5843137255, blue: 0.1058823529, alpha: 1)
        appointmentSchedulingView.selectedDateView.layer.borderWidth = 1
        appointmentSchedulingView.scheduleBtn.isEnabled = false
        configureCollectionView()
    }
    
    private func configureCollectionView() {
       let apView = appointmentSchedulingView
       apView?.collectionView.register(AppointmentTimeCell.self)
       apView?.collectionView.delegate = self
       apView?.collectionView.dataSource = self
   }
}

// MARK: - CollectionView DataSource
extension ScheduleAppointmentCell: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: AppointmentTimeCell.self, for: indexPath)
        cell.timeLbl.text = "10:00 AM"
        cell.configure(selectedTimeCell == indexPath ? .selected : .normal, indexPath: indexPath)
        if selectedTimeCell == indexPath{
            appointmentSchedulingView.scheduleBtn.isEnabled = true
        }
        
        appointmentSchedulingView.collectionViewHeight.constant = collectionView.contentSize.height
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let temp = selectedTimeCell
       selectedTimeCell =  indexPath
       collectionView.reloadItems(at: [indexPath, temp ?? IndexPath(row: 0, section: 0)])
    }
}

// MARK: - CollectionView FlowLayout Deleget
extension ScheduleAppointmentCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = ( appointmentSchedulingView.collectionView.bounds.width - 67 )/3
        return CGSize(width: width, height: 40)
    }
}

// MARK: - ConfigurableProtocol
extension ScheduleAppointmentCell: ConfigurableCell {
    typealias DataType = ScheduleCellDecoration
    
    func configure(_ item: ScheduleCellDecoration, indexPath: IndexPath) {
        if item == .expanded{
            appointmentSchedulingView.isHidden = false
            appointmentSchedulingView.dateBackgroundView.isHidden = false
        }else{
            appointmentSchedulingView.isHidden = true
        }
    }
    
    func configure(_ item: ScheduleCellDecoration, isTimesloatHide: Bool = true, indexPath: IndexPath) {
        if item == .expanded{
            appointmentSchedulingView.isHidden = false
            appointmentSchedulingView.dateBackgroundView.isHidden = false
        }else{
            appointmentSchedulingView.isHidden = true
        }
        arrowImg.image = item == .expanded ? UIImage(named: "arrowUp") : UIImage(named: "arrowDown")
    }
}
 
// MARK: - Configuration Enum
enum ScheduleCellDecoration{
    case noramal
    case expanded
    
}
