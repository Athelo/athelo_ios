//
//  PopoverView.swift
//  Athelo
//
//  Created by Devsto on 01/02/24.
//

import UIKit


protocol PopoverActions {
    func PopoverActions(Action type: PopoverView.ResponseType, On index:Int)
}

class PopoverView: UIViewController {

    @IBOutlet weak var popupBackgroungView: UIView!
    
    var index: Int?
    var responseActions: PopoverActions?
    
    init() {
        super.init(nibName: "PopoverView", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
    
    private func configure() {
        popupBackgroungView.layer.borderWidth = 1
        popupBackgroungView.layer.borderColor = #colorLiteral(red: 0.8901960784, green: 0.8901960784, blue: 0.8901960784, alpha: 1)
    }
    
    private func showCancelPopUp(){
        let yesAction = PopupActionData(title: "action.yes".localized(), customStyle: .destructive) {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
                self.showReshedualPopup()
            }
        }
        
        let noAction = PopupActionData(title: "action.no".localized())
        
        let popupData = PopupConfigurationData(template: .cancelAppointment, primaryAction: yesAction, secondaryAction: noAction)
        
        AppRouter.current.windowOverlayUtility.displayPopupView(with: popupData)
    }
    
    private func showReshedualPopup(){
        let yesAction = PopupActionData(title: "action.yes".localized(), customStyle: .main) {
            print("Navigat to reschedule screen")
            self.responseActions?.PopoverActions(Action: .reschedule, On: self.index!)
        }
        
        let noAction = PopupActionData(title: "action.no".localized()){
            print("Remove Appointment from list")
            self.responseActions?.PopoverActions(Action: .delete, On: self.index!)
        }
        
        let popupData = PopupConfigurationData(template: .reschedual, primaryAction: yesAction, secondaryAction: noAction)
        AppRouter.current.windowOverlayUtility.displayPopupView(with: popupData)
    }
    

    @IBAction func onClickJoinBtn(_ sender: UIControl) {
        sender.backgroundColor = #colorLiteral(red: 0.4274509804, green: 0.4274509804, blue: 0.4274509804, alpha: 0.07)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3){
            self.responseActions?.PopoverActions(Action: .join, On: self.index!)
            sender.backgroundColor = .clear
        }
    }
    
    @IBAction func onClickCancelBtn(_ sender: UIControl) {
        self.dismiss(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.4){
            self.showCancelPopUp()
        }
    }
}

extension PopoverView {
    enum ResponseType {
        case delete
        case join
        case reschedule
    }
}
