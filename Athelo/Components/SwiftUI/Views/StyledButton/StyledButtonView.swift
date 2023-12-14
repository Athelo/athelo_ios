//
//  StyledButtonView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 27/06/2022.
//

import SwiftUI

struct StyledButtonView: UIViewRepresentable {
    let title: String
    let style: StyledButton.Style
    private let imageData: ImageData?
    let tapHandler: () -> Void
    
    typealias UIViewType = StyledButton
    
    init(title: String, style: StyledButton.Style = .main, imageData: ImageData? = nil, tapHandler: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.imageData = imageData
        self.tapHandler = tapHandler
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> StyledButton {
        let button = StyledButton()
        
        button.addTarget(context.coordinator, action: #selector(Coordinator.handleButtonTap), for: .touchUpInside)
        
        return button
    }
    
    func updateUIView(_ uiView: StyledButton, context: Context) {
        uiView.setTitle(title, for: .normal)
        uiView.style = style
        
        if let imageData {
            uiView.setImage(imageData.image.withRenderingMode(imageData.renderingMode), for: .normal)

            if let highlightColor = imageData.selectionColor {
                uiView.imageTintColorOnActivation = highlightColor
            }
            
            uiView.imageEdgeInsets = UIEdgeInsets(right: 32.0)
            uiView.contentEdgeInsets = UIEdgeInsets(left: 16.0)
        }
        
        context.coordinator.tapHandler = tapHandler
    }
}

extension StyledButtonView {
    final class Coordinator {
        var tapHandler: (() -> Void)?
        
        @objc fileprivate func handleButtonTap(_ sender: Any?) {
            tapHandler?()
        }
    }
    
    struct ImageData {
        let image: UIImage
        let renderingMode: UIImage.RenderingMode
        let selectionColor: UIColor?
        
        init(image: UIImage, renderingMode: UIImage.RenderingMode = .automatic, selectionColor: UIColor? = nil) {
            self.image = image
            self.renderingMode = renderingMode
            self.selectionColor = selectionColor
        }
    }
}

struct StyledButtonView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16.0) {
            StyledButtonView(title: "action.ok".localized(), style: .main, tapHandler: { /* ... */ })
                .frame(height: 52.0, alignment: .center)
            
            StyledButtonView(title: "action.cancel".localized(), style: .secondary, imageData: .init(image: .init(named: "person")!, selectionColor: .withStyle(.purple623E61)), tapHandler: { /* ... */ })
                .frame(height: 52.0, alignment: .center)
            
            StyledButtonView(title: "action.delete".localized(), style: .destructive, tapHandler: { /* ... */ })
                .frame(height: 52.0, alignment: .center)
        }
        .padding()
    }
}
