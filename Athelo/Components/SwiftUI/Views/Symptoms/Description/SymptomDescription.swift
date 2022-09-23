//
//  SymptomDescription.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 18/07/2022.
//

import SwiftUI

struct SymptomDescriptionView: View {
    let data: SymptomData
    private let geometry: GeometryProxy?
    private let offset: CGFloat?
    
    init(data: SymptomData, geometry: GeometryProxy? = nil, offset: CGFloat? = nil) {
        self.data = data
        self.geometry = geometry
        self.offset = offset
    }
    
    var body: some View {
        VStack(spacing: 32.0) {
//            StyledText("General information about symptom: \(data.name)", textStyle: .headline20, colorStyle: .black, extending: true, alignment: .leading)
            
            if let description = data.description, !description.isEmpty {
                HTMLContent(
                    text: description,
                    geometry: geometry,
                    offset: offset)
            }
        }
    }
}

struct SymptomDescription_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            ScrollView {
                SymptomDescriptionView(data: SymptomData.sample(), geometry: geometry)
            }
        }
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
    
    static func sample() -> SymptomData {
        SymptomData(id: 2, name: "Difficulty swallowing", description: "Lorem ipsum dolor sit amet.")
    }
}
