//
//  SymptomListView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 18/07/2022.
//

import SwiftUI

struct SymptomListView: View {
    @ObservedObject private(set) var model: SymptomListModel
    let itemSelectedAction: (SymptomData) -> Void
    
    var body: some View {
        GeometryReader { _ in
            ScrollView(.vertical) {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 51.0, alignment: .center)
                
                VStack(spacing: 16.0) {
                    ForEach(model.entries) { entry in
                        ListTileView(data:
                                .init(data: entry,
                                      displaysNavigationChevron: true,
                                      forceTitleLeadingOffset: true)
                        )
                        .transition(.opacity)
                        .onTapGesture {
                            itemSelectedAction(entry)
                        }
                    }
                }
                .transition(.opacity)
                .animation(.default)
                .padding([.leading, .trailing, .bottom], 16.0)
//                .padding(.top, 67.0)
                .background(Rectangle().fill(.clear))
            }
        }
    }
}

struct SymptomListView_Previews: PreviewProvider {
    private static let model = SymptomListModel(entries: SymptomData.samples())
    
    static var previews: some View {
        SymptomListView(model: model) { _ in
            /* ... */
        }
    }
}

private extension SymptomData {
    init(id: Int, name: String, icon: LoadableImageData? = nil) {
        self.id = id
        self.name = name
        
        self.icon = nil
        self.description = nil
        self.isPublic = true
    }
    
    static func samples() -> [SymptomData] {
        [
            SymptomData(id: 1, name: "Fatigue", icon: .image(.init(named: "symptomBladder")!)),
            SymptomData(id: 2, name: "Difficulty swallowing"),
            SymptomData(id: 3, name: "Hoarseness")
        ]
    }
}
