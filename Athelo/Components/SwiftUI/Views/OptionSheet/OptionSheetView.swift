//
//  OptionSheetView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/03/2023.
//

import SwiftUI

struct OptionSheetView: View {
    @StateObject var model: OptionSheetModel
    
    @State private(set) var visible: Bool = false
    
    var body: some View {
        VStack(spacing: 0.0) {
            Spacer()
            
            if model.visible {
                VStack(spacing: 16.0) {
                    if !model.actions.isEmpty {
                        VStack(spacing: 32.0) {
                            ForEach(model.actions) { action in
                                HStack(alignment: .center, spacing: 16.0) {
                                    Image(uiImage: action.icon.withRenderingMode(.alwaysTemplate))
                                        .scaledToFit()
                                        .foregroundColor(Color(action.actionColor.cgColor))
                                        .frame(width: 24.0, height: 24.0)
                                    
                                    StyledText(
                                        action.name,
                                        textStyle: .button,
                                        colorStyle: action.actionStyle,
                                        alignment: .leading
                                    )
                                }
                                .frame(height: 24.0)
                                .onTapGesture {
                                    action.action()
                                    dismiss()
                                }
                            }
                        }
                        .padding(24.0)
                        .background(
                            Rectangle()
                                .fill(Color(UIColor.withStyle(.white).cgColor))
                        )
                        .roundedCorners(radius: 30.0)
                        .styledShadow()
                    }
                    
                    StyledButtonView(
                        title: "action.cancel".localized(),
                        style: .secondary,
                        tapHandler: {
                            dismiss()
                        }
                    )
                    .frame(height: 52.0)
                }
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .bottom),
                        removal: .move(edge: .bottom)
                    )
                    .combined(with: .opacity)
                )
            }
        }
        .padding(.horizontal, 16.0)
    }
    
    private func dismiss() {
        AppRouter.current.windowOverlayUtility.hideCustomOverlayView(withPinningTag: ViewPinningTags.optionSheet, animated: true)
        model.toggleVisibility()
    }
}

struct OptionSheetView_Previews: PreviewProvider {
    static let model = OptionSheetModel(actions: [
        OptionSheetItem(
            name: "Test :)",
            icon: UIImage(named: "envelope")!,
            action: { /* ... */ }
        ),
        OptionSheetItem(
            name: "Test :)",
            icon: UIImage(named: "envelope")!,
            destructive: true,
            action: { /* ... */ }
        )
    ])
    
    static var previews: some View {
        VStack(spacing: 40.0) {
            OptionSheetView(model: model)
            
            Button("Toggle!") {
                model.toggleVisibility()
            }
        }
    }
}
