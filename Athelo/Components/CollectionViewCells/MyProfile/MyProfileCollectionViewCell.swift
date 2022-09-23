//
//  MyProfileCollectionViewCell.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 13/06/2022.
//

import SwiftDate
import UIKit

protocol MyProfileCollectionViewCellDelegate: AnyObject {
    func myProfileCollectionViewCellAsksToEditProfile(_ cell: MyProfileCollectionViewCell)
}

final class MyProfileCollectionViewCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet private weak var buttonEdit: UIButton!
    @IBOutlet private weak var imageViewAvatar: UIImageView!
    @IBOutlet private weak var labelBirthDate: UILabel!
    @IBOutlet private weak var labelPhoneNumber: UILabel!
    @IBOutlet private weak var stackViewBirthDate: UIStackView!
    @IBOutlet private weak var stackViewPhoneNumber: UIStackView!
    @IBOutlet private weak var textViewName: UITextView!
    @IBOutlet private weak var viewContentContainer: UIView!
    
    // MARK: - Propoerties
    private weak var delegate: MyProfileCollectionViewCellDelegate?
    
    // MARK: - View lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateNameTextViewMaskingPath()
    }
    
    // MARK: - Public API
    func assignDelegate(_ delegate: MyProfileCollectionViewCellDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Configuration
    private func configure() {
        configureNameTextView()
    }
    
    private func configureNameTextView() {
        textViewName.removePadding()
    }
    
    // MARK: - Updates
    private func updateNameTextViewMaskingPath() {
        let buttonRect = viewContentContainer.convert(buttonEdit.frame, to: textViewName)
        
        let exclusionPath = UIBezierPath(rect: buttonRect)
        textViewName.textContainer.exclusionPaths = [exclusionPath]
    }
    
    // MARK: - Actions
    @IBAction private func editButtonTapped(_ sender: Any) {
        delegate?.myProfileCollectionViewCellAsksToEditProfile(self)
    }
}

// MARK: - Protocol conformance
// MARK: ConfigurableCell
extension MyProfileCollectionViewCell: ConfigurableCell {
    typealias DataType = IdentityProfileData
    
    func configure(_ item: IdentityProfileData, indexPath: IndexPath) {
        imageViewAvatar.displayLoadableImage(item.avatarImage(in: imageViewAvatar.bounds.size, borderStyle: .roundedRect(25.0)))
        
        textViewName.text = item.displayName
        
        if let dateOfBirth = item.dateOfBirth?.toFormat("MMMM yyyy") {
            labelBirthDate.text = dateOfBirth
        } else {
            labelBirthDate.text = "\("message.noinformation".localized())"
        }
        
        if let phoneNumber = item.phoneNumber, !phoneNumber.isEmpty {
            labelPhoneNumber.text = phoneNumber
        } else {
            labelPhoneNumber.text = "\("message.noinformation".localized())"
        }
    }
}
