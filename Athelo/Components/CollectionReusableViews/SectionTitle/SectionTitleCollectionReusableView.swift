//
//  SectionTitleCollectionReusableView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 10/06/2022.
//

import UIKit

typealias SectionTitleDecorationData = SectionTitleCollectionReusableView.DecorationData

protocol SectionTitleCollectionReusableViewDelegate: AnyObject {
    func sectionTitleCollectionReusableView(_ view: SectionTitleCollectionReusableView, activatedInteractableItem identifier: String)
}

final class SectionTitleCollectionReusableView: UICollectionReusableView {
    // MARK: - Constants
    struct DecorationData {
        let title: String
        let font: UIFont
        let interactableData: [InteractableItemData]?
        
        init(title: String, font: UIFont = .withStyle(.subheading), interactableData: [InteractableItemData]? = nil) {
            self.title = title
            self.font = font
            self.interactableData = interactableData
        }
    }
    
    struct InteractableItemData {
        let key: String
        let substring: String
    }
    
    // MARK: - Outlets
//    @IBOutlet private weak var labelTitle: InteractableLabel!
    @IBOutlet private weak var textViewTitle: UITextView!
    
    // MARK: - Properties
    private weak var delegate: SectionTitleCollectionReusableViewDelegate?
    
    // MARK: - View lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
    }
    
    // MARK: - Public API
    func assignDelegate(_ delegate: SectionTitleCollectionReusableViewDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Configuration
    private func configure() {
        configureTitleTextView()
    }
    
    private func configureTitleTextView() {
        textViewTitle.removePadding()
        
//        textViewTitle.delegate = self
    }
    
    // MARK: - Actions
    @objc private func handleInnerTap(_ sender: Any) {
        guard let tapGestureRecognizer = sender as? UITapGestureRecognizer else {
            return
        }
        
        let tapLocation = tapGestureRecognizer.location(in: textViewTitle)
        guard let textPosition = textViewTitle.closestPosition(to: tapLocation),
              let positionStyling = textViewTitle.textStyling(at: textPosition, in: .forward),
              let url = positionStyling[.link] as? URL else {
            return
        }
        
        if url.scheme == "athelo", let host = url.host {
            delegate?.sectionTitleCollectionReusableView(self, activatedInteractableItem: host)
        }
    }
}

// MARK: - Protocol conformance
// MARK: ConfigurableCell
extension SectionTitleCollectionReusableView: ConfigurableCell {
    typealias DataType = SectionTitleDecorationData
    
    func configure(_ item: SectionTitleDecorationData, indexPath: IndexPath) {
        textViewTitle.text = item.title
        textViewTitle.font = item.font
        
        if let interactableItems = item.interactableData {
            guard let attributedText = textViewTitle.attributedText else {
                return
            }
            
            let updatedAttributedText = NSMutableAttributedString(attributedString: attributedText)
            for interactableItem in interactableItems {
                let range = (attributedText.string as NSString).range(of: interactableItem.substring)
                guard range.location != NSNotFound else {
                    continue
                }
                
                guard let customURL = URL(string: "athelo://\(interactableItem.key)") else {
                    continue
                }
                
                updatedAttributedText.addAttribute(.link, value: customURL, range: range)
                updatedAttributedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            }
            
            textViewTitle.attributedText = updatedAttributedText
            
            weak var weakSelf = self
            let tapGestureRecognizer = UITapGestureRecognizer(target: weakSelf, action: #selector(handleInnerTap(_:)))
            
            textViewTitle.addGestureRecognizer(tapGestureRecognizer)
        }
    }
}
