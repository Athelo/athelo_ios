//
//  AppointmentBooked.swift
//  Athelo
//
//  Created by Devsto on 30/01/24.
//

import UIKit


final class AppointmentBookedCell: UITableViewCell{
    
    // MARK: - Outlets
    
    @IBOutlet weak var professionLbl: UILabel!
    @IBOutlet weak var personNameLbl: UILabel!
    @IBOutlet weak var profileImgView: UIImageView!
    
    @IBOutlet weak var timeZoneLbl: UILabel!
    @IBOutlet weak var dateTimeLbl: UILabel!
    @IBOutlet weak var dateBgView: UIView!
    
    
    @IBOutlet weak var backGroundView: UIView!
    
    
    
    // MARK: - View lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    
    
    // MARK: - Configuration
    private func configure() {
        configureOwnView()
    }
    
    private func configureOwnView() {
        selectionStyle = .none
        clipsToBounds = false
        
        let shadowLayer = CAShapeLayer()
        
        shadowLayer.shadowColor = UIColor.withStyle(.shadow).cgColor
        shadowLayer.shadowOpacity = 0.08
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        shadowLayer.shadowRadius = 18.0
        
        layer.addSublayer(shadowLayer)
        
        
        
        
    }
    
    
    @IBAction func onClickMoreBtn(_ sender: UIButton) {
    }
    
}
