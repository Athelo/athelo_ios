//
//  HTMLContent.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 22/06/2022.
//

import SwiftUI

struct HTMLContentLabel: UIViewRepresentable {
    typealias UIViewType = UILabel
    
    @Binding var attributedText: NSAttributedString
    private let onURLTapAction: ((URL) -> Void)?
    
    init(attributedText: Binding<NSAttributedString>, onURLTapAction: ((URL) -> Void)? = nil) {
        self._attributedText = attributedText
        self.onURLTapAction = onURLTapAction
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onURLTapAction: onURLTapAction)
    }
    
    func makeUIView(context: Context) -> UILabel {
        let label = BodyLabel()
        
        label.isUserInteractionEnabled = true
        label.numberOfLines = 0
//        label.tintColor = .withStyle(.purple80627F)
        
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        
        let gestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLabelTap(_:)))
        label.addGestureRecognizer(gestureRecognizer)
        
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.attributedText = attributedText
    }
}

extension HTMLContentLabel {
    final class Coordinator {
        private let onURLTapAction: ((URL) -> Void)?
        
        init(onURLTapAction: ((URL) -> Void)? = nil) {
            self.onURLTapAction = onURLTapAction
        }
        
        @objc fileprivate func handleLabelTap(_ sender: Any?) {
            guard let sender = sender as? UITapGestureRecognizer,
                  let label = sender.view as? UILabel,
                  let attributedText = label.attributedText, !attributedText.string.isEmpty else {
                return
            }
            
            let labelTapPoint = sender.location(in: label)
            guard label.bounds.contains(labelTapPoint) else {
                return
            }
            
            let textStorage = NSTextStorage(attributedString: attributedText)
            
            let layoutManager = NSLayoutManager()
            textStorage.addLayoutManager(layoutManager)
            
            let textContainer = NSTextContainer(size: label.frame.size)
            textContainer.lineFragmentPadding = 0.0
            layoutManager.addTextContainer(textContainer)
            
            let charaterIndex = layoutManager.characterIndex(for: labelTapPoint, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
            guard charaterIndex != NSNotFound else {
                return
            }
            
            let knownAttributes = attributedText.attributes(at: charaterIndex, effectiveRange: nil)
            guard let url = knownAttributes[.link] as? URL else {
                return
            }
            
            onURLTapAction?(url)
        }
    }
}

struct HTMLContent: View {
    @Binding private var attributedText: NSAttributedString
    private let onURLTapAction: ((URL) -> Void)?
    
    private let geometry: GeometryProxy?
    private let offset: CGFloat?
    
    init(attributedString: NSAttributedString, geometry: GeometryProxy? = nil, offset: CGFloat? = nil, onURLTapAction: ((URL) -> Void)? = nil) {
        self._attributedText = .constant(attributedString)
        
        self.geometry = geometry
        self.offset = offset
        self.onURLTapAction = onURLTapAction
    }
    
    init(text: String, font: UIFont = .withStyle(.body), textAlignment: NSTextAlignment = .natural, geometry: GeometryProxy? = nil, offset: CGFloat? = 0.0, onURLTapAction: ((URL) -> Void)? = nil) {
        if let data = text.htmlDecorated(font: font).data(using: .utf8),
            let htmlString = try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.24
            paragraphStyle.alignment = textAlignment

            htmlString.addAttributes([.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: htmlString.length))

            self._attributedText = .constant(htmlString)
        } else {
            self._attributedText = .constant(NSAttributedString(string: text))
        }
        
        self.geometry = geometry
        self.offset = offset
        self.onURLTapAction = onURLTapAction
    }
    
    var body: some View {
        HTMLContentLabel(attributedText: $attributedText, onURLTapAction: onURLTapAction)
            .frame(minHeight: heightOfString(), alignment: .center)
    }
    
    func heightOfString() -> CGFloat {
        guard let geometry = geometry else {
            return 0.0
        }
        
        return ceil(attributedText.boundingRect(with: .init(width: geometry.size.width - (offset ?? 0.0), height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin], context: nil).height)
    }
}

struct HTMLContent_Previews: PreviewProvider {
    static var previews: some View {
        HTMLContent(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum aliquet est nec justo pellentesque accumsan. Nullam id lorem aliquet, iaculis nisl in, aliquet ante. Integer sit amet turpis auctor orci varius consequat. Morbi ut ante at justo egestas maximus. Cras sem nibh, elementum suscipit facilisis vel, ultrices ac nibh. Morbi et dignissim eros. Vestibulum nibh eros, fermentum sollicitudin egestas quis, tincidunt vitae lorem. Nulla auctor, eros vel posuere convallis, ex ligula commodo risus, ut pharetra metus enim id mi. Maecenas laoreet velit justo, pulvinar viverra libero placerat vitae. Integer dignissim lacinia nibh. Aliquam erat volutpat.")
            .padding()
    }
}
