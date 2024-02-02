//
//  ScheduleAppointmentCell.swift
//  Athelo
//
//  Created by Devsto on 31/01/24.
//
import UIKit


final class ScheduleAppointmentCell: UITableViewCell, UICollectionViewDelegate{
    
    
 
    @IBOutlet weak var professionLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    
    @IBOutlet weak var arrowImg: UIButton!
    @IBOutlet weak var choosDateView: UIView!
    
    @IBOutlet weak var submiteBtn: StyledButton!
    @IBOutlet weak var clanderView: AppointmnetCalanderView!
    // MARK: - View lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    private func configure() {
        configureOwnView()
    }
    
    private func configureOwnView() {
        selectionStyle = .none
        clanderView.collectionView.register(AppointmentTimeCell.self)
        clanderView.collectionView.delegate = self
        clanderView.collectionView.dataSource = self
        clanderView.dateBackgroundView.isHidden = false
        clanderView.selectedDateView.layer.borderColor = #colorLiteral(red: 0.4078431373, green: 0.5843137255, blue: 0.1058823529, alpha: 1)
        clanderView.selectedDateView.layer.borderWidth = 1
        
        
        
        
    }
    
    
    @IBAction func submiteActionBtn(_ sender: StyledButton) {
        clanderView.dateBackgroundView.isHidden.toggle()
        clanderView.timeSlotView.isHidden = !clanderView.dateBackgroundView.isHidden
    }
    
}


extension ScheduleAppointmentCell: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: AppointmentTimeCell.self, for: indexPath)
        cell.timeLbl.text = "10:00 AM"
        cell.timeView.layer.borderWidth = 1
        cell.timeView.layer.borderColor = #colorLiteral(red: 0.5019607843, green: 0.3843137255, blue: 0.4980392157, alpha: 1)
        return cell
    }
}

extension ScheduleAppointmentCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var width = ( clanderView.collectionView.bounds.width - 67 )/3
        
        return CGSize(width: width, height: 40)
    }
}
