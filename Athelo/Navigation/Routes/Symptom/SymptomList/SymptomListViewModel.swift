//
//  SymptomListViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 18/07/2022.
//

import Combine
import UIKit

final class SymptomListViewModel: BaseViewModel {
    // MARK: - Constants
    enum Filter: Int, CaseIterable {
        case dailytracker
        case symptomhistory
        
        var name: String {
            switch self {
            case .dailytracker:
                return "symptoms.filter.dailytracker".localized()
            case .symptomhistory:
                return "symptoms.filter.symptomhistory".localized()
            }
        }
    }
    
    // MARK: - Properties
  
    
    private let filterSubject = CurrentValueSubject<Filter, Never>(.dailytracker)
    var filterPublisher: AnyPublisher<Filter, Never> {
        filterSubject
            .eraseToAnyPublisher()
    }
    var filter: Filter {
        filterSubject.value
    }
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    override init() {
        super.init()
        
    }
    
}
