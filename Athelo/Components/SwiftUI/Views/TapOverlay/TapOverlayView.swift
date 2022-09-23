//
//  TapOverlayView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 29/07/2022.
//

import SwiftUI

struct TapOverlayView: UIViewRepresentable {
    private(set) var callback: ((CGPoint, CGSize) -> Void)
    private(set) var dragStateCallback: ((Bool) -> Void)?
    
    typealias UIViewType = UIView
    
    final class Coordinator: NSObject {
        var callback: ((CGPoint, CGSize) -> Void)
        var dragStateCallback: ((Bool) -> Void)?
        
        init(callback: @escaping (CGPoint, CGSize) -> Void, dragStateCallback: ((Bool) -> Void)?) {
            self.callback = callback
            self.dragStateCallback = dragStateCallback
        }
        
        @objc fileprivate func viewDragged(_ gesture: UITapGestureRecognizer) {
            switch gesture.state {
            case .began:
                dragStateCallback?(true)
            case .cancelled, .ended, .failed:
                dragStateCallback?(false)
            default:
                break
            }
            
            let location = gesture.location(in: gesture.view)
            callback(location, gesture.view?.bounds.size ?? .zero)
        }
        
        @objc fileprivate func viewTapped(_ gesture: UITapGestureRecognizer) {
            let location = gesture.location(in: gesture.view)
            callback(location, gesture.view?.bounds.size ?? .zero)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(callback: self.callback, dragStateCallback: dragStateCallback)
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
    
        view.backgroundColor = .clear
        
        let dragGestureRecognizer = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.viewDragged(_:)))
        view.addGestureRecognizer(dragGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.viewTapped(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        /* ... */
    }
}

struct TapOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        TapOverlayView(callback: { _, _ in /* ... */ })
    }
}
