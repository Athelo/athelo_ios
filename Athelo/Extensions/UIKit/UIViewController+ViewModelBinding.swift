//
//  UIViewController+ViewModelBinding.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/06/2022.
//

import Combine
import Foundation
import UIKit

extension Routable where Self: UIViewController, RouterType: RouterProtocol {
    func bindToViewModel<C>(_ viewModel: BaseViewModel, cancellables: inout C) where C: RangeReplaceableCollection, C.Element == AnyCancellable {
        viewModel.state
            .receive(on: DispatchQueue.main)
            .filter({ [weak self] _ in self?.view.window != nil })
            .sink { [weak self] in
                self?.view.handleModelState($0)
            }.store(in: &cancellables)
        
        viewModel.message
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .filter({ [weak self] _ in self?.view.window != nil })
            .sink { [weak self] in
                self?.displayMessage($0.text, type: $0.type)
            }.store(in: &cancellables)
    }
}

private extension UIView {
    func handleModelState(_ modelState: ViewModelState) {
        switch modelState {
        case .error(let error):
            AppRouter.current.windowOverlayUtility.hideLoadingView()
            
            let message = error.toInfoMessageData()
            AppRouter.current.windowOverlayUtility.displayMessage(message.text, type: message.type)
        case .initial:
            break
        case .loaded:
            AppRouter.current.windowOverlayUtility.hideLoadingView()
        case .loading:
            AppRouter.current.windowOverlayUtility.displayLoadingView()
        }
    }
}
