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
    
    // MARK: - Properties
    var parentScreen: UIViewController!
    
    
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
        presentPopover(parentScreen, PopoverView(), sender: sender, size: CGSize(width: 256, height: 104))
        
        
    }
    
    private func presentPopover(_ parentViewController: UIViewController, _ viewController: UIViewController, sender: UIView, size: CGSize, arrowDirection: UIPopoverArrowDirection = .down) {
        
        viewController.preferredContentSize = size
        viewController.modalPresentationStyle = .popover
        if let pres = viewController.presentationController {
            pres.delegate = parentViewController
        }
        parentViewController.present(viewController, animated: true)
        if let pop = viewController.popoverPresentationController {
            pop.backgroundColor = #colorLiteral(red: 0.9176470588, green: 0.9176470588, blue: 0.9176470588, alpha: 1)
            pop.sourceView = sender
            let position = CGRectMake(sender.bounds.origin.x - 120, sender.bounds.origin.y + 70, sender.bounds.size.width, sender.bounds.size.height)
            pop.sourceRect = position
            pop.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        }
    }
    
}
