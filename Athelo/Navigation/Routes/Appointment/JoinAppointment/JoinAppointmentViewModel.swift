//
//  JoinAppointmentViewModel.swift
//  Athelo
//
//  Created by Devsto on 14/02/24.
//

import Combine
import UIKit

import AVFoundation

   
final class JoinAppointmentViewModel: BaseViewModel {
    
    let kApiKey = "47853731"

    // your generated session ID
    var kSessionId: String = ""

    // generated token
    var kToken = CurrentValueSubject<String, Never>("")
    

    var firstMicroPermission = false
    var firstCameraPermission = false
    private var cancellables: [AnyCancellable] = []
    
    
    override init() {
        super.init()
    
    }
    
 

    
}

extension JoinAppointmentViewModel {
    func getAppointmentDetail(ID id:Int){
        guard state.value != .loading else {
            return
        }
        state.send(.loading)
        
        AtheloAPI.Appointment.getAppointmentDetail(request: .init(id: id))
            .sink { compilation in
                switch compilation{
                case .failure(let error):
                    print(error.localizedDescription)
                case .finished: break
                }
            } receiveValue: {
                self.getVonageDetail(ID: $0.id)
                self.kSessionId = $0.vonageSession ?? ""
            }
            .store(in: &cancellables)
    }
    
    private func getVonageDetail(ID id:Int){
        AtheloAPI.Appointment.getVonageDetail(request: .init(id: id))
            .sink { compilation in
                switch compilation{
                case .failure(let error):
                    print(error.localizedDescription)
                case .finished: break
                }
            } receiveValue: { [weak self] vonage in
                self?.kToken.send(vonage.token)
            }
            .store(in: &cancellables)
    }
}

extension JoinAppointmentViewModel {
    enum Permissions{
        case camera
        case microphone
        
    }
    
    
    func checkBlutoothPermission() -> Bool {

        var permissionCheck: Bool = false

        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
                permissionCheck = true
        case AVAudioSession.RecordPermission.denied:
                permissionCheck = false
        case AVAudioSession.RecordPermission.undetermined:
            firstMicroPermission = true
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                if granted {
                    permissionCheck = true
                } else {
                    permissionCheck = false
                }
            })
            
        default:
            break
        }
        
        return permissionCheck
    }
    
    func checkCameraPermission() -> Bool {
        var permissionCheck: Bool = false

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionCheck = true
        case .denied, .restricted:
            permissionCheck = false
        case .notDetermined:
            firstCameraPermission = true
            AVCaptureDevice.requestAccess(for: .video) { granted in
                permissionCheck = granted
            }
        @unknown default:
            break
        }

        return permissionCheck
    }
}
