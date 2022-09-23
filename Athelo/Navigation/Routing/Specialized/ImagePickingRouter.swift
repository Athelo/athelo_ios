//
//  ImagePickingRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 20/06/2022.
//

import Foundation
import PhotosUI
import UIKit

struct ImagePickerConfigurationData {
    enum SelectionType {
        case camera
        case singleImage
        case multipleImages
        
        fileprivate var selectionLimit: Int? {
            switch self {
            case .camera, .singleImage:
                return 1
            case .multipleImages:
                return 0
            }
        }
        
        fileprivate var sourceType: UIImagePickerController.SourceType {
            switch self {
            case .camera:
                return .camera
            case .multipleImages, .singleImage:
                return .photoLibrary
            }
        }
    }
    
    let selectionType: SelectionType
    weak private(set) var delegate: UIViewController?
}

protocol ImagePickingRoutable: RouterProtocol {
    func navigateToImagePickerController(using configurationData: ImagePickerConfigurationData)
}

extension ImagePickingRoutable where Self: Router {
    func navigateToImagePickerController(using configurationData: ImagePickerConfigurationData) {
        guard UIImagePickerController.isSourceTypeAvailable(configurationData.selectionType.sourceType) else {
            return
        }

        guard let navigationController = navigationController else {
            fatalError("Cannot present Image Picker controller on navigation stack from \(String(describing: self)) instance - missing navigation controller instance.")
        }
        
        if #available(iOS 14.0, *), configurationData.delegate is PHPickerViewControllerDelegate, configurationData.selectionType.sourceType == .photoLibrary {
            guard let delegate = configurationData.delegate as? PHPickerViewControllerDelegate else {
                fatalError("Cannot present Image Picker controller on navigation stack from \(String(describing: self)) instance - delegate doesn't conform to \(PHPickerViewControllerDelegate.self).")
            }
            
            var pickerConfiguration = PHPickerConfiguration()
            pickerConfiguration.filter = .images
            
            if let selectionLimit = configurationData.selectionType.selectionLimit, selectionLimit >= 0 {
                pickerConfiguration.selectionLimit = selectionLimit
            }
            
            let pickerController = PHPickerViewController(configuration: pickerConfiguration)
            
            pickerController.delegate = delegate
            
            navigationController.present(pickerController, animated: true)
        } else {
            guard let delegate = configurationData.delegate as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate) else {
                fatalError("Cannot present Image Picker controller on navigation stack from \(String(describing: self)) instance - delegate doesn't conform to \(UIImagePickerControllerDelegate.self).")
            }
            
            let pickerController = UIImagePickerController()
            
            pickerController.sourceType = configurationData.selectionType.sourceType
            pickerController.allowsEditing = false
            pickerController.delegate = delegate
            
            if configurationData.selectionType.sourceType == .camera {
                pickerController.cameraCaptureMode = .photo
            }
            
            navigationController.present(pickerController, animated: true)
        }
    }
}

extension UIImagePickerControllerDelegate where Self: UIViewController, Self: UINavigationControllerDelegate {
    func displayPhotoChangePrompt(with router: ImagePickingRoutable?, withMultipleItemsIfPossible fetchMultipleItems: Bool = false) {
        showPhotoChangePrompt(using: router, withMultipleItemsIfPossible: fetchMultipleItems)
    }
}

@available(iOS 14, *)
extension PHPickerViewControllerDelegate where Self: UIViewController {
    func displayPhotoChangePrompt(with router: ImagePickingRoutable?, withMultipleItemsIfPossible fetchMultipleItems: Bool = false) {
        showPhotoChangePrompt(using: router, withMultipleItemsIfPossible: fetchMultipleItems)
    }
}

fileprivate extension UIViewController {
    func showPhotoChangePrompt(using router: ImagePickingRoutable?, withMultipleItemsIfPossible fetchMultipleItems: Bool = false) {
        let takePhotoAction = PopupActionData(title: "action.photo.take".localized()) { [weak self] in
            router?.navigateToImagePickerController(using: .init(selectionType: .camera, delegate: self))
        }
        let selectPhotoAction = PopupActionData(title: "action.photo.select".localized(), customStyle: .main) { [weak self] in
            var selectionType: ImagePickerConfigurationData.SelectionType = .singleImage
            if #available(iOS 14.0, *), fetchMultipleItems {
                selectionType = .multipleImages
            }
            
            router?.navigateToImagePickerController(using: .init(selectionType: selectionType, delegate: self))
        }
        
        let popupData = PopupConfigurationData.init(template: .selectPhoto, primaryAction: takePhotoAction, secondaryAction: selectPhotoAction)
        AppRouter.current.windowOverlayUtility.displayPopupView(with: popupData)
    }
}
