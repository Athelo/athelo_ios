//
//  SymptomsDailyListView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 18/07/2022.
//

import Combine
import SwiftUI

struct SymptomsDailyListView: View {
    @ObservedObject private(set) var model: SymptomsDailyListModel
    
    private let loadMoreSubject = PassthroughSubject<Void, Never>()
    var loadMorePublisher: AnyPublisher<Void, Never> {
        loadMoreSubject
            .eraseToAnyPublisher()
    }
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 24.0) {
                ForEach(model.items) { item in
                    SymptomDaySummaryView(data: item)
                }
                
                if model.shouldLoadMore {
                    LoadMoreView()
                        .frame(height: 44.0, alignment: .center)
                        .onAppear {
                            loadMoreSubject.send()
                        }
                }
            }
            .animation(.default, value: model.items)
            .padding(.top, 24.0)
            .padding(.bottom, 16.0)
        }
    }
}

struct SymptomsDailyListView_Previews: PreviewProvider {
    private static let model = SymptomsDailyListModel(items: SymptomDaySummaryData.samples(), shouldLoadMore: true)
    
    static var previews: some View {
        SymptomsDailyListView(model: model)
    }
}

private extension SymptomDaySummaryData {
    static func samples() -> [SymptomDaySummaryData] {
        (0...11).map({
            SymptomDaySummaryData(date: Date().dateByAdding(-$0, .month).date, symptoms: SymptomData.samples().map({ UserSymptomData(symptom: $0) }), feeling: FeelingData.sample())
        })
    }
}

private extension UserSymptomData {
    init(symptom: SymptomData) {
        self.id = Int.random(in: 0...Int.max)
        self.note = nil
        self.updatedAt = Date()
        self.createdAt = Date()
        
        self.symptom = symptom
        
        self.occurrenceDate = Date()
    }
}

private extension SymptomData {
    init(id: Int, name: String) {
        self.id = id
        self.name = name
        
        self.icon = nil
        self.description = nil
        self.isPublic = true
    }
    
    static func randomSymptomName() -> String {
        ["Fatigue", "Difficulty swallowing", "Hoarseness", "Unexplained bleeding", "Persistent fevers or night sweats", "Persistent night sweats", "Skin darkening or redness", "Sores that won't heal", "Changes to existing moles", "Persistent cough and persistent fevers or night sweats", "Persistent joint pain", "Persistent muscle", "Discomfort after eating"].randomElement()!
    }
    
    static func samples() -> [SymptomData] {
        Set((1...10).map({ _ in randomSymptomName() })).enumerated().map({ (idx, item) in
            SymptomData(id: idx + 1, name: item)
        })
    }
}

private extension FeelingData {
    init(id: Int, feeling: Int) {
        self.id = id
        self.generalFeeling = feeling
        
        self.note = nil
        self.occurrenceDate = Date()
    }
    
    static func sample() -> FeelingData {
        FeelingData(id: Int.random(in: 0...Int.max), feeling: Int.random(in: 1...100))
    }
}
