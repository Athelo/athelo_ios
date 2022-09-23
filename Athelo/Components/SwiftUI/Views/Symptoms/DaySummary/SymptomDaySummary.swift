//
//  SymptomDaySummaryView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 18/07/2022.
//

import SwiftDate
import SwiftUI

struct SymptomDaySummaryData: Identifiable {
    let date: Date
    let feeling: FeelingData?
    let symptoms: [UserSymptomData]
    
    init(date: Date, symptoms: [UserSymptomData], feeling: FeelingData? = nil) {
        self.date = date
        self.symptoms = symptoms
        self.feeling = feeling
    }
    
    var id: Date {
        date
    }
}

extension SymptomDaySummaryData: Equatable {
    static func == (lhs: SymptomDaySummaryData, rhs: SymptomDaySummaryData) -> Bool {
        lhs.date.compare(toDate: rhs.date, granularity: .day) == .orderedSame
        && lhs.feeling?.generalFeeling == rhs.feeling?.generalFeeling
        && Set(lhs.symptoms.map({ $0.symptom.id })) == Set(rhs.symptoms.map({ $0.symptom.id }))
    }
}

struct SymptomDayRowData: Identifiable {
    let id: UUID
    let items: [UserSymptomData]
    
    init(items: [UserSymptomData]) {
        self.id = UUID()
        self.items = items
    }
}

struct SymptomDaySummaryView: View {
    let data: SymptomsDailyListModel.ListItem
    
    @State private(set) var items: [SymptomDayRowData] = []
    
    private var symptomList: String {
        data.symptomData.symptoms.map({ $0.symptom.name })
            .sorted(by: \.self, using: { lhs, rhs in
                lhs.localizedCaseInsensitiveCompare(rhs) == .orderedAscending
            })
            .joined(separator: ", ")
    }
    
    var body: some View {
        VStack(spacing: 0.0) {
            if data.displaysYearSeparator {
                StyledText("symptoms.chronology.items.year".localized(arguments: [data.symptomData.date.year]),
                           textStyle: .subtitle,
                           colorStyle: .purple623E61,
                           extending: false,
                           alignment: .center)
                .padding(.vertical, 4.0)
            }
            
            HStack(alignment: .center, spacing: 8.0) {
                VStack(spacing: 8.0) {
                    VStack(spacing: 6.0) {
                        StyledText("\(data.symptomData.date.day)",
                                   textStyle: .headline20,
                                   colorStyle: .purple623E61,
                                   extending: false,
                                   alignment: .center)
                        
                        StyledText("\(data.symptomData.date.monthName(.short))",
                                   textStyle: .subheading,
                                   colorStyle: .purple623E61,
                                   extending: false,
                                   alignment: .center)
                    }

                    StyledText("\(data.symptomData.date.weekdayName(.short))", textStyle: .body, colorStyle: .gray, extending: false, alignment: .center)
                }
                .frame(width: 40.0, alignment: .center)
                
                VStack(alignment: .leading, spacing: 8.0) {
                    HStack(alignment: .bottom, spacing: 16.0) {
                        StyledText("symptoms.chronology.items.header".localized(),
                                   textStyle: .subtitle,
                                   colorStyle: .gray,
                                   alignment: .leading)
                        .frame(minHeight: 30.0, alignment: .bottom)
                        
                        if let emoji = data.symptomData.feeling?.feeling.emoji {
                            Text(emoji)
                                .font(.system(size: 24.0))
                        }
                    }
                    
                    StyledText(symptomList,
                               textStyle: .body,
                               colorStyle: .purple80627F,
                               alignment: .leading)
                }
                .padding([.leading, .trailing, .bottom], 16.0)
                .padding(.top, 4.0)
                .background(Rectangle().fill(.white))
                .cornerRadius(16.0)
                .styledShadow()
            }
        }
        
        .padding([.leading, .trailing], 16.0)
    }
}

struct SymptomDaySummaryView_Previews: PreviewProvider {
    static var previews: some View {
            ScrollView(.vertical) {
                SymptomDaySummaryView(data: .init(symptomData: .init(date: Date(), symptoms: SymptomData.samples().map({ UserSymptomData(symptom: $0) }), feeling:  FeelingData.sample()), displaysYearSeparator: true))
            }
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
        ["Fatigue", "Difficulty swallowing", "Hoarseness", "Unexplained bleeding", "Persistent fevers or night sweats", "Persistent night sweats", "Skin darkening or redness", "Sores that won't heal", "Changes to existing moles", "Persistent cough", "Persistent joint pain", "Persistent muscle", "Discomfort after eating"].randomElement()!
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
