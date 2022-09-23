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
    let tapHandler: () -> Void
    
    typealias UIViewType = StyledButton
    
    init(title: String, style: StyledButton.Style = .main, tapHandler: @escaping () -> Void) {
        self.title = title
        self.style = style
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
}

struct StyledButtonView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16.0) {
            StyledButtonView(title: "action.ok".localized(), style: .main, tapHandler: { /* ... */ })
                .frame(height: 52.0, alignment: .center)
            
            StyledButtonView(title: "action.cancel".localized(), style: .secondary, tapHandler: { /* ... */ })
                .frame(height: 52.0, alignment: .center)
            
            StyledButtonView(title: "action.delete".localized(), style: .destructive, tapHandler: { /* ... */ })
                .frame(height: 52.0, alignment: .center)
        }
        .padding()
    }
}
