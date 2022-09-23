//
//  SymptomDescriptionListView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 18/07/2022.
//

import SwiftUI

struct SymptomDescriptionListView: View {
    @ObservedObject private(set) var model: SymptomListModel
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                VStack(alignment: .center, spacing: 32.0) {
                    ForEach(model.entries) { symptom in
                        SymptomDescriptionView(
                            data: symptom,
                            geometry: geometry,
                            offset: 32.0
                        )
                    }
                }
                .padding(.horizontal, 16.0)
                .padding(.bottom, model.extendsBottomContent ? 16.0 : 84.0)
                .padding(.top, 24.0)
            }
        }
    }
}

struct SymptomDescriptionListView_Previews: PreviewProvider {
    private static let model = SymptomListModel(entries: SymptomData.samples())
    
    static var previews: some View {
        SymptomDescriptionListView(model: model)
    }
}

private extension SymptomData {
    init(id: Int, name: String, description: String) {
        self.id = id
        self.name = name
        self.description = description
        
        self.icon = nil
        self.isPublic = true
    }
    
    static func samples() -> [SymptomData] {
        [
            SymptomData(id: 2, name: "Difficulty swallowing", description: "Donec et enim at odio auctor laoreet."),
            SymptomData(id: 3, name: "Difficulty swallowing", description: "Praesent commodo est sit amet neque vulputate vestibulum id at purus."),
        ]
    }
}
