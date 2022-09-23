//
//  InteractableLabel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 09/06/2022.
//

import UIKit

protocol InteractableLabelDelegate: AnyObject {
    func interactableLabel(_ label: InteractableLabel, selectedTextWithIdentifier identifier: String)
}

final class InteractableLabel: BodyLabel {
    // MARK: - Properties
    private var registeredRanges: [(Range<String.Index>, String)] = []
    private weak var delegate: InteractableLabelDelegate?

    private var handledTouchEventTimestamps: [TimeInterval] = []

    // MARK: - Initialization / lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        isUserInteractionEnabled = true
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let testResult = super.hitTest(point, with: event)

        if testResult == self {
            if let eventTimestamp = event?.timestamp {
                guard !handledTouchEventTimestamps.contains(eventTimestamp) else {
                    return testResult
                }
            }

            if handleOwnRegionTap(at: point, event: event),
               let eventTimestamp = event?.timestamp {
                handledTouchEventTimestamps.append(eventTimestamp)
            }
        }

        return testResult
    }

    // MARK: - Public API
    func assignDelegate(_ delegate: InteractableLabelDelegate) {
        self.delegate = delegate
    }

    func markSubstringAsInteractable(_ substring: String, identifier: String) {
        guard let substringRange = text?.range(of: substring) else {
            return
        }

        registeredRanges.append((substringRange, identifier))
    }

    // MARK: - Actions
    private func handleOwnRegionTap(at point: CGPoint, event: UIEvent?) -> Bool {
        guard !registeredRanges.isEmpty, let ownedText = attributedText?.string ?? text else {
            return false
        }

        guard let textStorage: NSTextStorage = {
            if let attributedText = attributedText {
                return NSTextStorage(attributedString: attributedText)
            } else if let text = text {
                return NSTextStorage(string: text)
            } else {
                return nil
            }
        }() else {
            return false
        }

        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(size: frame.size)
        textContainer.lineFragmentPadding = 0
        layoutManager.addTextContainer(textContainer)

        for (registeredRange, rangeIdentifier) in registeredRanges {
            let nsRange = NSRange(registeredRange, in: ownedText)

            let glyphRange = layoutManager.characterRange(forGlyphRange: nsRange, actualGlyphRange: nil)
            let glyphRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)

            if glyphRect.contains(point) {
                delegate?.interactableLabel(self, selectedTextWithIdentifier: rangeIdentifier)
                return true
            }
        }

        return false
    }
}
