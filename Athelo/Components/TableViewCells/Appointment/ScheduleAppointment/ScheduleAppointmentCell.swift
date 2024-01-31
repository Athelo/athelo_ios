//
//  ScheduleAppointmentCell.swift
//  Athelo
//
//  Created by Devsto on 31/01/24.
//
import UIKit


final class ScheduleAppointmentCell: UITableViewCell{
 
    
    
    
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
    }
    
    
    
}
