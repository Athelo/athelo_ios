//
//  JoinAppointmnetViewController.swift
//  Athelo
//
//  Created by Devsto on 13/02/24.
//

import UIKit
import OpenTok
import Combine

class JoinAppointmnetViewController: BaseViewController {

    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet weak var publisherVideoView: UIView!
    @IBOutlet weak var sbscribVideoView: UIView!
    
    lazy var session: OTSession = {
        return OTSession(apiKey: viewModel.kApiKey, sessionId:  viewModel.kSessionId, delegate: self)!
    }()
    lazy var publisher: OTPublisher = {
        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        return OTPublisher(delegate: self, settings: settings)!
    }()
    
    private var viewModel = JoinAppointmentViewModel()
    private var router: JoineAppointmentRouter?
    private var cancellables: [AnyCancellable] = []
    
    var subscriber: OTSubscriber?
    var appointmentID: Int!
    var screenWidth: Double = 0
    var screenHight: Double = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
        
        viewModel.getAppointmentDetail(ID: appointmentID)
        screenHight = self.view.frame.height
        screenWidth = self.view.frame.width
        
    }
    
    // MARK: - Configuration
    private func configure() {

    }
    
    private func configurePermissions() {
        
        if !(viewModel.checkBlutoothPermission()) && !viewModel.firstMicroPermission {
            showPermissionPopup(For: .microphone)
        }else{
            if !(self.viewModel.checkCameraPermission()) && !viewModel.firstCameraPermission {
                self.showPermissionPopup(For: .camera)
            }
        }
        
    }
    
    
    // MARK: - Sink
    private func sink(){
        sinkIntoViewModel()
    }
    
    private func sinkIntoViewModel() {
        bindToViewModel(viewModel, cancellables: &cancellables)
        
        viewModel.kToken.sink { [weak self] in
            if $0 != "" {
                self?.doConnect()
            }
        }
        .store(in: &cancellables)
    }
    
    private func showPermissionPopup(For unit: JoinAppointmentViewModel.Permissions) {
        let popup = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        popup.title = "popup.permission.\(unit).titel".localized()
        popup.message = "popup.permission.\(unit).message".localized()
        
        let cancelBtn = UIAlertAction(title: "action.cancel".localized(), style: .cancel) { _ in
            if !(self.viewModel.checkCameraPermission()) && unit == .microphone{
                self.showPermissionPopup(For: .camera)
            }
        }
        let setting = UIAlertAction(title: "action.settings".localized(), style: .default){ _ in
            if !(self.viewModel.checkCameraPermission()) && unit == .microphone{
                self.showPermissionPopup(For: .camera)
            }
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        
        popup.addAction(cancelBtn)
        popup.addAction(setting)
        
        self.present(popup, animated: true)
    }
    
    @IBAction func onClickCloseBtn(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}


// MARK: Navigatable
extension JoinAppointmnetViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .appointment
    }
}

// MARK: Routable
extension JoinAppointmnetViewController: Routable {
    func assignRouter(_ router: JoineAppointmentRouter) {
        self.router = router
    }
}



extension JoinAppointmnetViewController {
    /**
     * Asynchronously begins the session connect process. Some time later, we will
     * expect a delegate method to call us back with the results of this action.
     */
    fileprivate func doConnect() {
        var error: OTError?
        defer {
            processError(error)
        }
        
        if let pubView = publisher.view {
            pubView.frame = CGRect(x: 0, y: 0, width: 110, height: 150)
            pubView.layer.borderColor = UIColor.white.cgColor
            pubView.layer.borderWidth = 1
            DispatchQueue.main.async {
                self.publisherVideoView.addSubview(pubView)
            }
            
        }
        session.connect(withToken: viewModel.kToken.value, error: &error)
        
    }
    
    /**
     * Sets up an instance of OTPublisher to use with this session. OTPubilsher
     * binds to the device camera and microphone, and will provide A/V streams
     * to the OpenTok session.
     */
    fileprivate func doPublish() {
        var error: OTError?
        defer {
            processError(error)
        }
        
        session.publish(publisher, error: &error)
        
       
    }
    
    /**
     * Instantiates a subscriber for the given stream and asynchronously begins the
     * process to begin receiving A/V content for this stream. Unlike doPublish,
     * this method does not add the subscriber to the view hierarchy. Instead, we
     * add the subscriber only after it has connected and begins receiving data.
     */
    fileprivate func doSubscribe(_ stream: OTStream) {
        var error: OTError?
        defer {
            processError(error)
        }
        subscriber = OTSubscriber(stream: stream, delegate: self)
        
        session.subscribe(subscriber!, error: &error)
    }
    
    fileprivate func cleanupSubscriber() {
        subscriber?.view?.removeFromSuperview()
        subscriber = nil
    }
    
    fileprivate func cleanupPublisher() {
        publisher.view?.removeFromSuperview()
    }
    
    fileprivate func processError(_ error: OTError?) {
        if let err = error {
            DispatchQueue.main.async {
                let controller = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - OTSession delegate callbacks
extension JoinAppointmnetViewController: OTSessionDelegate {
    func sessionDidConnect(_ session: OTSession) {
        print("Session connected")
        doPublish()
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        print("Session disconnected")
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("Session streamCreated: \(stream.streamId)")
        if subscriber == nil {
            doSubscribe(stream)
        }
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("Session streamDestroyed: \(stream.streamId)")
        if let subStream = subscriber?.stream, subStream.streamId == stream.streamId {
            cleanupSubscriber()
        }
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("session Failed to connect: \(error.localizedDescription)")
    }
    
}

// MARK: - OTPublisher delegate callbacks
extension JoinAppointmnetViewController: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
        viewModel.state.send(.loaded)
        print("Publishing")
        configurePermissions()
        
        
    }
    
    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        cleanupPublisher()
        if let subStream = subscriber?.stream, subStream.streamId == stream.streamId {
            cleanupSubscriber()
        }
        viewModel.state.send(.loaded)
    }
    
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        viewModel.state.send(.loaded)
        print("Publisher failed: \(error.localizedDescription)")
    }
}

// MARK: - OTSubscriber delegate callbacks
extension JoinAppointmnetViewController: OTSubscriberDelegate {
    func subscriberDidConnect(toStream subscriberKit: OTSubscriberKit) {
       
        if let subsView = subscriber?.view {
            subsView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHight)
            DispatchQueue.main.async {
                self.sbscribVideoView.addSubview(subsView)
            }
        }
    }
    
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("Subscriber failed: \(error.localizedDescription)")
    }
}
