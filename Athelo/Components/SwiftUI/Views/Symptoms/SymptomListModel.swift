//
//  SymptomListModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 18/07/2022.
//

import Foundation

final class SymptomListModel: ObservableObject {
    @Published private(set) var entries: [SymptomData]
    @Published private(set) var extendsBottomContent: Bool = false
    
    init(entries: [SymptomData]) {
        self.entries = entries
    }
    
    func updateEntries(_ entries: [SymptomData]) {
        self.entries = entries
    }
    
    func updateExtendedBottomContentState(_ state: Bool) {
        guard state != extendsBottomContent else {
            return
        }
        
        extendsBottomContent = state
    }
}

