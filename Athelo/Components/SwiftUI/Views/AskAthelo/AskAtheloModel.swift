//
//  AskAtheloModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 27/06/2022.
//

import SwiftUI

final class AskAtheloModel: ObservableObject {
    @Published private(set) var entries: [ExpandableEntryData]
    
    init(entries: [ExpandableEntryData]) {
        self.entries = entries
    }
    
    func addEntry(_ entry: ExpandableEntryData) {
        self.entries.insert(entry, at: 0)
    }
    
    func updateEntries(_ entries: [ExpandableEntryData]) {
        self.entries = entries
    }
}
