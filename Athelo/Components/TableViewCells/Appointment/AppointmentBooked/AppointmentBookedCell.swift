//
//  AppointmentBooked.swift
//  Athelo
//
//  Created by Devsto on 30/01/24.
//

import UIKit
// MARK: - Configuration Enum
struct AppointmentCellDecoration{
    
    var appointmentData: AppointmetntData
    
    init(_ appointmentData: AppointmetntData) {
        self.appointmentData = appointmentData
    }
    
}


final class AppointmentBookedCell: UITableViewCell{
    
    // MARK: - Outlets
    @IBOutlet weak var professionLbl: UILabel!
    @IBOutlet weak var personNameLbl: UILabel!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var timeZoneLbl: UILabel!
    @IBOutlet weak var dateTimeLbl: UILabel!
    @IBOutlet weak var dateBgView: UIView!
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var loadingView: LoadingView!
    
    // MARK: - Properties
    var parentScreen: AppointmentViewController!
    var index: IndexPath!
    
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
        backgroundColor = .none
    }
    
    
    @IBAction func onClickMoreBtn(_ sender: UIButton) {
        let popoverView = PopoverView()
        popoverView.index = self.index.row
        popoverView.reschedualBtnClicked = self.parentScreen.routToReschedualVC
        popoverView.cancelAppointmentClicked = self.parentScreen.appointmentRemoveSuccess
        presentPopover(parentScreen, popoverView, sender: sender, size: CGSize(width: 256, height: 104))
        
        
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

extension AppointmentBookedCell: ConfigurableCell {
    
    typealias DataType = AppointmentCellDecoration
    
    func configure(_ item: AppointmentCellDecoration, indexPath: IndexPath) {
        var data = item.appointmentData
        personNameLbl.text = data.provider.name
        let globelTime = data.startTime.toDate(style: .custom("yyyy-MM-dd'T'HH:mm:ss"), region: .local)
        dateTimeLbl.text = globelTime?.toString(.custom("dd MMM, hh:mm a"))
        let localTimeZoneOffsetSeconds = TimeZone.current.secondsFromGMT()
        let hours = localTimeZoneOffsetSeconds / 3600
        let minutes = (localTimeZoneOffsetSeconds % 3600) / 60
        timeZoneLbl.text = String(format: "GMT%+03d:%02d", hours, minutes)
        index = indexPath
        setProileImage(Form: URL(string: data.provider.photo))
        dateBgView.layer.borderColor = #colorLiteral(red: 0.4078431373, green: 0.5843137255, blue: 0.1058823529, alpha: 1)
        dateBgView.layer.borderWidth = 1
    }
    
    private func setProileImage(Form url:URL?){
        loadingView.isHidden = false
        profileImgView.isHidden = true
        profileImgView.sd_setImage(with: url) { image, err, _, _ in
            self.loadingView.isHidden = true
            self.profileImgView.isHidden = false
            self.profileImgView.image = image
            if let _ = err {
                self.profileImgView.image = UIImage(named: "logoSmall")
            }
        }
    }
    
    
    
    
}
