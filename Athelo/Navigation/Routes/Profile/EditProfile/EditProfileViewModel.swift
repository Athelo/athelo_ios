//
//  EditProfileViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 15/06/2022.
//

import Combine
import SwiftDate
import UIKit

final class EditProfileViewModel: BaseViewModel {
    // MARK: - Properties
    private let targetAvatarPhoto = CurrentValueSubject<UIImage?, Never>(nil)
    private let targetBirthDate = CurrentValueSubject<Date?, Never>(nil)
    private let targetName = CurrentValueSubject<String?, Never>(nil)
    private let targetPhoneNumber = CurrentValueSubject<String?, Never>(nil)
    
    private let targetUserType = CurrentValueSubject<UserTypeConstant?, Never>(nil)
    
    var knownBirthDate: Date {
        targetBirthDate.value ?? Date().dateByAdding(-50, .year).dateAt(.startOfMonth).dateByAdding(14, .day).date
    }
    
    var userTypePublisher: AnyPublisher<UserTypeConstant, Never> {
        targetUserType
            .compactMap({ $0 })
            .eraseToAnyPublisher()
    }
    var userType: UserTypeConstant? {
        targetUserType.value
    }
    
    @Published private(set) var avatarData: LoadableImageData?
    @Published private(set) var editsContent: Bool = false
    @Published private(set) var hasPendingChanges: Bool = false
    @Published private(set) var userData: IdentityProfileData?
    
    private var lockedInEditMode: Bool = false
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        sink()
    }
    
    // MARK: - Public API
    func assignAvatarPhoto(_ photo: UIImage?) {
        targetAvatarPhoto.send(photo)
        
        if let photo = photo {
            avatarData = .image(photo)
        } else {
            avatarData = nil
        }
    }
    
    func assignBirthDate(_ birthDate: Date?) {
        targetBirthDate.send(birthDate)
    }
    
    func assignName(_ name: String?) {
        targetName.send(name)
    }
    
    func assignPhoneNumber(_ phoneNumber: String?) {
        targetPhoneNumber.send(phoneNumber)
    }
    
    func assignUserType(_ userType: UserTypeConstant?) {
        targetUserType.send(userType)
    }
    
    func lockEditMode() {
        if !editsContent {
            switchEditMode()
        }
        
        lockedInEditMode = true
    }
    
    func resetPassword() {
        guard state.value != .loading,
              let email = userData?.email, !email.isEmpty else {
            return
        }
        
        state.send(.loading)
        
        let request = PasswordResetRequest(email: email, type: .link)
        AtheloAPI.Passwords.reset(request: request)
            .sink { [weak self] result in
                switch result {
                case .finished:
                    self?.state.send(.loaded)
                case .failure(let error):
                    self?.state.send(.error(error: error))
                }
            } receiveValue: { [weak self] value in
                self?.message.send(.init(text: value.detail, type: .success))
            }.store(in: &cancellables)
    }
    
    func sendRequest() {
        guard state.value != .loading else {
            return
        }
        
        guard let name = targetName.value, !name.isEmpty else {
            message.send(.init(text: "message.noname".localized(), type: .error))
            return
        }
        
        state.send(.loading)
        
        let photoUploadPublisher: AnyPublisher<Int?, Error> = {
            if let avatarPhoto = targetAvatarPhoto.value {
                let imageDataFuture = Future<Data, Error> { promise in
                    DispatchQueue.global(qos: .default).async {
                        guard let imageData = avatarPhoto.jpegData(compressionQuality: 1.0) else {
                            promise(.failure(CocoaError(.coderInvalidValue)))
                            return
                        }
                        
                        promise(.success(imageData))
                    }
                }
                
                return imageDataFuture
                    .flatMap({ data -> AnyPublisher<Int?, Error> in
                        let request = ImagesUploadRequest(imageData: data)
                        return (AtheloAPI.Images.upload(request: request) as AnyPublisher<ImageData, APIError>)
                            .map({ $0.id })
                            .mapError({ $0 as Error })
                            .eraseToAnyPublisher()
                    })
                    .eraseToAnyPublisher()
            } else {
                return Just(nil)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
        }()
        
        let originalPhotoID = userData?.photo?.id
        let params: [String: Any] = generateUpdatesDict()
        
        photoUploadPublisher
            .map({ photoID -> [String: Any] in
                var targetParams = params
                
                if let photoID = photoID {
                    targetParams["photo_id"] = photoID
                }
                
                return targetParams
            })
            .mapError({ $0 as Error })
            .flatMap({ params -> AnyPublisher<IdentityProfileData, Error> in
                return IdentityUtility.updateUserProfile(using: params)
            })
            .handleEvents(receiveOutput: { [weak self] value in
                guard let originalPhotoID = originalPhotoID, value.photo?.id != originalPhotoID,
                      let self = self else {
                    return
                }
                
                let request = ImagesDeleteRequest(imageID: originalPhotoID)
                AtheloAPI.Images.delete(request: request)
                    .sink { _ in
                        /* ... */
                    }.store(in: &self.cancellables)
            })
            .sink { [weak self] result in
                self?.state.send(result.toViewModelState())
            } receiveValue: { [weak self] value in
                self?.userData = value
                if !(self?.lockedInEditMode == true) {
                    self?.editsContent = false
                }
                
                self?.resetCachedFormData()
            }.store(in: &cancellables)
    }
    
    func switchEditMode() {
        if editsContent, lockedInEditMode {
            return
        }
        
        editsContent.toggle()
        
        if editsContent {
            resetCachedFormData()
        }
    }
    
    func userTypesPublisher() -> AnyPublisher<[ListInputCellItemData], Error> {
        Deferred {
            ConstantsStore.constantsPublisher()
                .map({ $0.userTypes })
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoIdentityManager()
    }
    
    private func sinkIntoIdentityManager() {
        IdentityUtility.userDataPublisher
            .sink { [weak self] in
                self?.userData = $0
            }.store(in: &cancellables)
        
        IdentityUtility.userDataPublisher
            .map({ $0?.avatarImage(in: .init(width: 96.0, height: 96.0)) })
            .sink { [weak self] in
                self?.avatarData = $0
            }.store(in: &cancellables)
        
        $userData
            .compactMap({ $0?.userType })
            .flatMap({ value -> AnyPublisher<UserTypeConstant?, Error> in
                return ConstantsStore.constantsPublisher()
                    .map({ $0.userTypes })
                    .map({ innerValue -> UserTypeConstant? in
                        innerValue.first(where: { $0.id == value })
                    })
                    .eraseToAnyPublisher()
            })
            .sink { result in
                /* ... */
            } receiveValue: { [weak self] in
                self?.targetUserType.send($0)
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func generateUpdatesDict() -> [String: Any] {
        var params: [String: Any] = [:]
        
        if let birthDate = targetBirthDate.value,
           birthDate.toFormat("yyyy-MM") != userData?.dateOfBirth?.toFormat("yyyy-MM") {
            params["date_of_birth"] = "\(birthDate.toFormat("yyyy-MM"))-15"
        }
        
        if let name = targetName.value,
           name != userData?.displayName {
            params["display_name"] = name
        }
        
        if targetPhoneNumber.value != userData?.phoneNumber {
            params["phone_number"] = targetPhoneNumber.value ?? NSNull()
        }
        
        if let userType = userType,
           userType.id != userData?.userType {
            params["athelo_user_type"] = userType.id
        }
        
        return params
    }
    
    private func resetCachedFormData() {
        targetAvatarPhoto.send(nil)
        targetBirthDate.send(userData?.dateOfBirth)
        targetName.send(userData?.displayName)
        targetPhoneNumber.send(userData?.phoneNumber)
        
        ConstantsStore.constantsPublisher()
            .first()
            .map({ $0.userTypes })
            .sink { _ in
                /* ... */
            } receiveValue: { [weak self] userTypes in
                if let userType = userTypes.first(where: { $0.id == self?.userData?.userType }) {
                    self?.targetUserType.send(userType)
                }
            }.store(in: &cancellables)
    }
}
