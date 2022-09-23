//
//  EditProfileViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 15/06/2022.
//

import Combine
import SwiftDate
import SwiftUI
import UIKit

final class EditProfileViewController: KeyboardListeningViewController {
    // MARK: - Outlets
    @IBOutlet private weak var buttonEditPersonalInfo: StyledButton!
    @IBOutlet private weak var buttonRequestPasswordReset: StyledButton!
    @IBOutlet private weak var buttonUploadPicture: StyledButton!
    @IBOutlet private weak var contentScrollView: UIScrollView!
    @IBOutlet private weak var imageViewAvatar: UIImageView!
    @IBOutlet private weak var formTextFieldBirthDate: FormTextField!
    @IBOutlet private weak var formTextFieldEmail: FormTextField!
    @IBOutlet private weak var formTextFieldName: FormTextField!
    @IBOutlet private weak var formTextFieldPhoneNumber: FormTextField!
    @IBOutlet private weak var formTextFieldWhatDescribesYou: FormTextField!
    @IBOutlet private weak var stackViewActions: UIStackView!
    @IBOutlet private weak var stackViewAvatar: UIStackView!
    @IBOutlet private weak var stackViewContent: UIStackView!
    
    weak var birthDateInputHostingController: UIHostingController<CalendarView>?
    weak var userTypeInputView: ListInputView?
    
    // MARK: - Constraints
    @IBOutlet private weak var constraintStackViewActionsBottom: NSLayoutConstraint!
    @IBOutlet private weak var constraintScrollViewContentBottom: NSLayoutConstraint!
    @IBOutlet private weak var constraintStackViewContentBottom: NSLayoutConstraint!
    
    // MARK: - Properties
    private let viewModel = EditProfileViewModel()
    private var router: EditProfileRouter?
    
    private var birthDateDismissalGestureRecognizer: UITapGestureRecognizer?
    private var userTypeDismissalGestureRecognizer: UITapGestureRecognizer?
    
    private var shouldLockEditMode: Bool = false
    
    private var cancellables: [AnyCancellable] = []
    private var userTypeInputCancellable: AnyCancellable?
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
        
        if shouldLockEditMode {
            viewModel.lockEditMode()
        }
    }
    
    // MARK: - Configuration
    private func configure() {
        configureBirthDateFormTextField()
        configureEmailFormTextField()
        configureNameFormTextField()
        configureOwnView()
        configurePhoneNumberFormTextField()
        configureRequestPasswordResetButton()
        configureUploadPictureButton()
        configureWhatDescribesYouFormTextField()
    }
    
    private func configureBirthDateFormTextField() {
        formTextFieldBirthDate.delegate = self
        
        formTextFieldBirthDate.displayIcon(.calendar)
            .sink { [weak self] _ in
                guard self?.viewModel.editsContent == true else {
                    return
                }
                
                if self?.birthDateInputHostingController != nil {
                    self?.hideBirthDatePickerView()
                } else {
                    self?.displayBirthDateInputView()
                }
            }.store(in: &cancellables)
    }
    
    private func configureEmailFormTextField() {
        formTextFieldEmail.markInactive()
        
        formTextFieldEmail.delegate = self
    }
    
    private func configureNameFormTextField() {
        formTextFieldName.autocapitalizationType = .words
        formTextFieldName.autocorrectionType = .no
        formTextFieldName.returnKeyType = .done
        formTextFieldName.textContentType = .name
        
        formTextFieldName.delegate = self
    }
    
    private func configureOwnView() {
        title = "navigation.profile.edit".localized()
    }
    
    private func configurePhoneNumberFormTextField() {
        formTextFieldPhoneNumber.autocapitalizationType = .none
        formTextFieldPhoneNumber.autocorrectionType = .no
        formTextFieldPhoneNumber.keyboardType = .phonePad
        formTextFieldPhoneNumber.returnKeyType = .done
        formTextFieldPhoneNumber.textContentType = .telephoneNumber

        formTextFieldPhoneNumber.addToolbar()
        
        formTextFieldPhoneNumber.delegate = self
    }
    
    private func configureRequestPasswordResetButton() {
        buttonRequestPasswordReset.alpha = 0.0
        buttonRequestPasswordReset.isHidden = true
    }
    
    private func configureUploadPictureButton() {
        buttonUploadPicture.alpha = 0.0
        buttonUploadPicture.isHidden = true
    }
    
    private func configureWhatDescribesYouFormTextField() {
        formTextFieldWhatDescribesYou.delegate = self
        
        let iconTapPublisher = formTextFieldWhatDescribesYou.displayIcon(.verticalChevron)
        
        iconTapPublisher
            .sink { [weak self] in
                guard self?.viewModel.editsContent == true else {
                    return
                }
                
                if self?.userTypeInputView == nil {
                    self?.displayUserTypeInputView()
                } else {
                    self?.hideUserTypeInputView()
                    self?.view.endEditing(true)
                }
            }.store(in: &cancellables)
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoKeyboardChanges()
        sinkIntoNameFormTextField()
        sinkIntoPhoneNumberTextField()
        sinkIntoViewModel()
    }
    
    private func sinkIntoKeyboardChanges() {
        keyboardInfoPublisher
            .sink { [weak self] in
                if let self = self {
                    let targetOffset = $0.offsetFromScreenBottom > 0.0 ? 0.0 : -152.0
                    if targetOffset != self.constraintStackViewContentBottom.constant {
                        self.constraintStackViewContentBottom.constant = targetOffset
                    }
                    
                    self.adjustBottomOffset(using: self.constraintScrollViewContentBottom, keyboardChangeData: $0, additionalOffset: 152.0)
                }
            }.store(in: &cancellables)
    }
    
    private func sinkIntoNameFormTextField() {
        formTextFieldName.returnPublisher
            .sink { [weak self] in
                self?.view.endEditing(true)
            }.store(in: &cancellables)
        
        formTextFieldName.textPublisher
            .sink(receiveValue: viewModel.assignName(_:))
            .store(in: &cancellables)
    }
    
    private func sinkIntoPhoneNumberTextField() {
        formTextFieldPhoneNumber.returnPublisher
            .sink { [weak self] in
                self?.view.endEditing(true)
            }.store(in: &cancellables)
        
        formTextFieldPhoneNumber.textPublisher
            .sink(receiveValue: viewModel.assignPhoneNumber(_:))
            .store(in: &cancellables)
    }
    
    private func sinkIntoViewModel() {
        bindToViewModel(viewModel, cancellables: &cancellables)
        
        viewModel.$avatarData
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                if let value = value {
                    self?.imageViewAvatar.image = nil
                    self?.imageViewAvatar.contentMode = .scaleAspectFill
                    
                    self?.imageViewAvatar.displayLoadableImage(value)
                } else {
                    let image = UIImage(named: "imageSolid")?.sd_resizedImage(with: .init(width: 42.0, height: 42.0), scaleMode: .aspectFit)?.withRenderingMode(.alwaysTemplate)
                    
                    self?.imageViewAvatar.contentMode = .center
                    self?.imageViewAvatar.image = image
                }
            }.store(in: &cancellables)
        
        viewModel.$editsContent
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sinkDiscardingValue { [weak self] in
                self?.updateButtonsVisibility()
                self?.updateContentStackViewOffset()
                self?.updateFormTextFieldsEditability()
            }.store(in: &cancellables)
        
        viewModel.$editsContent
            .removeDuplicates()
            .map({ $0 ? "save" : "edit" })
            .map({ "action.personalinfo.\($0)".localized() })
            .receive(on: DispatchQueue.main)
            .sink { [weak button = buttonEditPersonalInfo] in
                button?.setTitle($0, for: .normal)
            }.store(in: &cancellables)
        
        viewModel.$userData
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.updateFormTextFieldsContents(using: $0)
            }.store(in: &cancellables)
        
        viewModel.userTypePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.formTextFieldWhatDescribesYou.text = $0.name
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func dismissAllInputs() {
        view.endEditing(true)
        
        hideBirthDatePickerView()
        hideUserTypeInputView()
    }
    
    private func displayBirthDateInputView() {
        guard birthDateInputHostingController == nil else {
            return
        }
        
        let inputView = CalendarView(date: viewModel.knownBirthDate, delegate: self)
        let inputViewController = UIHostingController(rootView: inputView)
        
        inputViewController.view.translatesAutoresizingMaskIntoConstraints = false
        inputViewController.view.alpha = 0.0
        inputViewController.view.backgroundColor = .clear
        
        addChild(inputViewController)
        contentScrollView.addSubview(inputViewController.view)
        
        adjustFrameOfFormInputView(inputViewController.view, inRelationTo: formTextFieldBirthDate, inside: stackViewContent, of: contentScrollView, estimatedComponentHeight: 212.0, forceAppendOnTop: true)

        birthDateInputHostingController = inputViewController
        
        formTextFieldBirthDate.activateIcon(.calendar)
        UIView.animate(withDuration: 0.3) {
            inputViewController.view.alpha = 1.0
        }
        
        inputViewController.didMove(toParent: self)
        
        weak var weakSelf = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: weakSelf, action: #selector(handleBirthDateInputViewDismissalGestureRecognizer(_:)))
        tapGestureRecognizer.delegate = self
        
        if let oldGestureRecognizer = birthDateDismissalGestureRecognizer {
            view.removeGestureRecognizer(oldGestureRecognizer)
        }
        view.addGestureRecognizer(tapGestureRecognizer)
        
        birthDateDismissalGestureRecognizer = tapGestureRecognizer
        
        view.endEditing(true)
    }
    
    private func displayUserTypeInputView() {
        guard userTypeInputView == nil else {
            return
        }
        
        let inputView = ListInputView.instantiate()
        
        inputView.translatesAutoresizingMaskIntoConstraints = false
        inputView.alpha = 0.0
        
        contentScrollView.addSubview(inputView)
        userTypeInputView = inputView
        
        adjustFrameOfFormInputView(inputView, inRelationTo: formTextFieldWhatDescribesYou, inside: stackViewContent, of: contentScrollView, estimatedComponentHeight: inputView.maximumExpectedContainerHeight)
        
        UIView.animate(withDuration: 0.3) {
            inputView.alpha = 1.0
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleUserTypeInputViewDismissalGestureRecognizer(_:)))
        tapGestureRecognizer.delegate = self
        
        if let oldGestureRecognizer = userTypeDismissalGestureRecognizer {
            view.removeGestureRecognizer(oldGestureRecognizer)
        }
        view.addGestureRecognizer(tapGestureRecognizer)
        
        userTypeDismissalGestureRecognizer = tapGestureRecognizer
        
        inputView.assignAndFireItemsPublisher(viewModel.userTypesPublisher(), preselecting: viewModel.userType)
        
        userTypeInputCancellable?.cancel()
        userTypeInputCancellable = inputView.selectedItemPublisher
            .compactMap({ $0 as? UserTypeConstant })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.formTextFieldWhatDescribesYou.text = value.name
                self?.viewModel.assignUserType(value)
                
                self?.hideUserTypeInputView()
                self?.view.endEditing(true)
            }
        
        view.endEditing(true)
        
        formTextFieldWhatDescribesYou.activateIcon(.verticalChevron)
    }
    
    @IBAction private func handleBirthDateInputViewDismissalGestureRecognizer(_ sender: Any?) {
        guard (sender as? UITapGestureRecognizer) == birthDateDismissalGestureRecognizer else {
            return
        }
        
        hideBirthDatePickerView()
    }
    
    @IBAction private func handleUserTypeInputViewDismissalGestureRecognizer(_ sender: Any?) {
        guard (sender as? UITapGestureRecognizer) == userTypeDismissalGestureRecognizer else {
            return
        }
        
        hideUserTypeInputView()
    }
    
    private func hideBirthDatePickerView() {
        guard birthDateInputHostingController != nil else {
            return
        }
        
        if let birthDateDismissalGestureRecognizer = birthDateDismissalGestureRecognizer {
            view.removeGestureRecognizer(birthDateDismissalGestureRecognizer)
        }
        
        formTextFieldBirthDate.deactivateIcon(.calendar)
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.birthDateInputHostingController?.view.alpha = 0.0
        } completion: { [weak self] completed in
            if completed {
                if let hostingController = self?.birthDateInputHostingController {
                    hostingController.view.removeFromSuperview()
                    hostingController.removeFromParent()
                    
                    self?.birthDateInputHostingController = nil
                }
            }
        }
    }
    
    private func hideUserTypeInputView() {
        guard userTypeInputView != nil else {
            return
        }
        
        if let userTypeDismissalGestureRecognizer = userTypeDismissalGestureRecognizer {
            view.removeGestureRecognizer(userTypeDismissalGestureRecognizer)
        }
        
        formTextFieldWhatDescribesYou.rotateIcon(.verticalChevron)
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.userTypeInputView?.alpha = 0.0
        } completion: { [weak self] completed in
            if completed {
                self?.userTypeInputView?.removeFromSuperview()
                self?.userTypeInputView = nil
            }
        }
    }
    
    private func updateButtonsVisibility() {
        let shouldHideEditActions = !viewModel.editsContent
        let shouldHideResetPasswordAction = shouldHideEditActions || (IdentityUtility.authenticationMethods?.containsNativeAuthData() == false)
        
        if buttonUploadPicture.isHidden != shouldHideEditActions {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.beginFromCurrentState]) { [weak button = buttonUploadPicture] in
                button?.isHidden.toggle()
                button?.alpha = button?.isHidden == true ? 0.0 : 1.0
            }
        }
        
        if buttonRequestPasswordReset.isHidden != shouldHideResetPasswordAction {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.beginFromCurrentState]) { [weak button = buttonRequestPasswordReset] in
                button?.isHidden.toggle()
                button?.alpha = button?.isHidden == true ? 0.0 : 1.0
            }
        }
    }
    
    private func updateContentStackViewOffset() {
        let targetOffset: CGFloat = viewModel.editsContent ? -152.0 : -86.0
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.beginFromCurrentState]) { [weak self] in
            self?.constraintStackViewContentBottom.constant = targetOffset
            self?.constraintStackViewActionsBottom.constant = -(targetOffset + 16.0)
            
            self?.view.layoutIfNeeded()
        }
    }
    
    private func updateFormTextFieldsContents(using profileData: IdentityProfileData) {
        formTextFieldEmail.text = profileData.email
        formTextFieldName.text = profileData.displayName
        formTextFieldPhoneNumber.text = profileData.phoneNumber
        formTextFieldBirthDate.text = profileData.dateOfBirth?.toFormat("MMMM yyyy")
    }
    
    private func updateFormTextFieldsEditability() {
        let canEdit = viewModel.editsContent
        
        [formTextFieldBirthDate,
         formTextFieldEmail,
         formTextFieldName,
         formTextFieldPhoneNumber,
         formTextFieldWhatDescribesYou].forEach({
            $0?.isUserInteractionEnabled = canEdit
        })
    }
    
    // MARK: - Actions
    @IBAction private func editPersonalInfoButtonTapped(_ sender: Any) {
        if viewModel.editsContent {
            dismissAllInputs()
            viewModel.sendRequest()
        } else {
            viewModel.switchEditMode()
        }
    }
    
    @IBAction private func requestPasswordResetButtonTapped(_ sender: Any) {
        dismissAllInputs()
        viewModel.resetPassword()
    }
    
    @IBAction private func uploadPictureButtonTapped(_ sender: Any) {
        dismissAllInputs()
        displayPhotoChangePrompt(with: router, withMultipleItemsIfPossible: false)
    }
}

// MARK: - Protocol conformance
// MARK: CalendarViewDelegate
extension EditProfileViewController: CalendarViewDelegate {
    func calendarViewUpdatedDate(_ date: Date) {
        if viewModel.knownBirthDate.year == date.year {
            hideBirthDatePickerView()
        }
        
        formTextFieldBirthDate.text = date.toFormat("MMMM yyyy")
        viewModel.assignBirthDate(date)
    }
}

// MARK: Configurable
extension EditProfileViewController: Configurable {
    struct ConfigurationData {
        let locksEditMode: Bool
    }
    
    func assignConfigurationData(_ configurationData: ConfigurationData) {
        if configurationData.locksEditMode {
            shouldLockEditMode = true
        }
    }
}

// MARK: Navigable
extension EditProfileViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .profile
    }
}

// MARK: Routable
extension EditProfileViewController: Routable {
    typealias RouterType = EditProfileRouter
    
    func assignRouter(_ router: EditProfileRouter) {
        self.router = router
    }
}

// MARK: UIGestureRecognizerDelegate
extension EditProfileViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let birthDateInputView = birthDateInputHostingController?.view,
           birthDateInputView.bounds.contains(touch.location(in: birthDateInputView)) {
            return false
        } else if let userTypeInputView = userTypeInputView,
                  userTypeInputView.bounds.contains(touch.location(in: userTypeInputView)) {
            return false
        }
        
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

// MARK: UIImagePickerControllerDelegate
extension EditProfileViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let selectedImage = (info[.editedImage] ?? info[.originalImage]) as? UIImage {
            Task { [weak self] in
                let rotatedImage = selectedImage.withFixedOrientation()
                self?.viewModel.assignAvatarPhoto(rotatedImage)
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: UINavigationControllerDelegate
extension EditProfileViewController: UINavigationControllerDelegate {
    /* ... */
}

// MARK: UITextFieldDelegate
extension EditProfileViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        formTextFieldName.containsInstanceOfTextField(textField) || formTextFieldPhoneNumber.containsInstanceOfTextField(textField)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if formTextFieldEmail.containsInstanceOfTextField(textField) {
            return false
        }
        
        if formTextFieldBirthDate.containsInstanceOfTextField(textField) {
            displayBirthDateInputView()
            hideUserTypeInputView()
            
            view.endEditing(true)
            return false
        } else if formTextFieldWhatDescribesYou.containsInstanceOfTextField(textField) {
            displayUserTypeInputView()
            hideBirthDatePickerView()
            
            view.endEditing(true)
            return false
        }
        
        if !viewModel.editsContent {
            return false
        }
        
        return true
    }
}
