//
//  FeedbackViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 23/06/2022.
//

import Combine
import UIKit

final class FeedbackViewModel: BaseViewModel {
    // MARK: - Constants
    private static let questionCategoryID: Int = 3
    
    // MARK: - Properties
    @Published private(set) var isValid: Bool = false
    @Published private(set) var selectedFeedbackTopic: FeedbackTopicData?
    
    private let text = CurrentValueSubject<String?, Never>(nil)
    
    private var shouldPreselectQuestionCategory: Bool = false
    
    private var cancellables: [AnyCancellable] = []
    private var preselectionCancellable: AnyCancellable?
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        sink()
    }
    
    // MARK: - Public API
    func assignFeedbackTopic(_ feedbackTopic: FeedbackTopicData) {
        if preselectionCancellable != nil {
            preselectionCancellable?.cancel()
            preselectionCancellable = nil
        }
        
        selectedFeedbackTopic = feedbackTopic
    }
    
    func assignText(_ text: String?) {
        self.text.send(text)
    }
    
    func feedbackTopicsPublisher() -> AnyPublisher<[ListInputCellItemData], Error> {
        Deferred {
            ConstantsStore.feedbackTopicsPublisher()
                .map({ $0 as [ListInputCellItemData] })
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    func sendRequest() {
        guard state.value != .loading, isValid,
              let topicID = selectedFeedbackTopic?.id,
              let text = text.value, !text.isEmpty else {
            return
        }
        
        state.send(.loading)
        
        let request = FeedbackRequest(message: text, type: .topic(topicID))
        (AtheloAPI.Feedback.sendFeedback(request: request) as AnyPublisher<FeedbackData, APIError>)
            .ignoreOutput()
            .sink { [weak self] in
                self?.state.send($0.toViewModelState())
                
                if case .finished = $0 {
                    self?.message.send(.init(text: "feedback.success".localized(), type: .success))
                    
                    self?.selectedFeedbackTopic = nil
                    self?.text.send(nil)
                    
                    if self?.shouldPreselectQuestionCategory == true {
                        self?.preselectQuestionTopicOption()
                    }
                }
            }.store(in: &cancellables)
    }
    
    func updatePreselectionToQuestionTopic() {
        guard !shouldPreselectQuestionCategory else {
            return
        }
        
        shouldPreselectQuestionCategory = true
        preselectQuestionTopicOption()
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoOwnSubjects() {
        let validTextPublisher = text.map({ $0?.isEmpty == false }).eraseToAnyPublisher()
        let validTopicPublisher = $selectedFeedbackTopic.map({ $0 != nil }).eraseToAnyPublisher()
        
        validTextPublisher
            .combineLatest(validTopicPublisher)
            .map({ $0 && $1 })
            .removeDuplicates()
            .sink { [weak self] in
                self?.isValid = $0
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func preselectQuestionTopicOption() {
        guard selectedFeedbackTopic == nil else {
            return
        }
        
        preselectionCancellable?.cancel()
        preselectionCancellable = ConstantsStore.feedbackTopicsPublisher()
            .map({
                $0.first(where: { $0.category == FeedbackViewModel.questionCategoryID })
            })
            .sink { _ in
                /* ... */
            } receiveValue: { [weak self] topic in
                if let topic = topic, self?.selectedFeedbackTopic == nil {
                    self?.selectedFeedbackTopic = topic
                }
            }
    }
}
