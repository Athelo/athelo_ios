//
//  ExpandableEntryView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 21/06/2022.
//

import SwiftUI

struct ExpandableEntryData: Identifiable {
    var title: String
    var content: String
    
    var id: Int {
        var hasher = Hasher()
        
        hasher.combine(title)
        hasher.combine(content)
        
        return hasher.finalize()
    }
}

final class ExpandableEntrySelectionModel: ObservableObject {
    @Published var selectedObject: ExpandableEntryData?
}

struct ExpandableEntryView: View {
    @EnvironmentObject var selectedObjectModel: ExpandableEntrySelectionModel
    
    private let entry: ExpandableEntryData
    private let geometry: GeometryProxy?
    private let additionalOffset: CGFloat
    private let onURLTapAction: ((URL) -> Void)?
    
    private var expanded: Bool {
        entry.id == selectedObjectModel.selectedObject?.id
    }
    
    init(entry: ExpandableEntryData, geometry: GeometryProxy? = nil, additionalOffset: CGFloat? = nil, onURLTapAction: ((URL) -> Void)? = nil) {
        self.entry = entry
        self.geometry = geometry
        self.additionalOffset = additionalOffset ?? 0.0
        self.onURLTapAction = onURLTapAction
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0.0) {
            HStack(spacing: 16.0) {
                HTMLContent(text: entry.title, geometry: geometry, offset: additionalOffset + 72.0, onURLTapAction: onURLTapAction)
                
                Image("arrowDown")
                    .rotationEffect(.degrees(expanded ? 180.0 : 0.0))
            }
            .padding(16.0)
            .frame(minHeight: 80.0, alignment: .center)
            .background(Rectangle().fill(.white), alignment: .center)
            .cornerRadius(20.0)
            .clipped()
            .styledShadow()
            .zIndex(2)
            .onTapGesture {
                withAnimation() {
                    if expanded {
                        selectedObjectModel.selectedObject = nil
                    } else {
                        selectedObjectModel.selectedObject = entry
                    }
                }
            }
            
            if expanded {
                HTMLContent(text: entry.content, geometry: geometry, offset: additionalOffset + 48.0, onURLTapAction: onURLTapAction)
                    .padding(16.0)
                    .background(Rectangle().fill(.white), alignment: .center)
                    .roundedCorners(radius: 20.0, corners: [.bottomLeft, .bottomRight])
                    .styledShadow()
                    .padding([.leading, .trailing], 8.0)
                    .offset(x: 0.0, y: -4.0)
                    .padding([.bottom], -4.0)
                    .zIndex(1)
                    .frame(maxHeight: expanded ? .greatestFiniteMagnitude : 0.0, alignment: .center)
                    .transition(.opacity)

            }
        }
    }
}

struct ExpandableEntryView_Previews: PreviewProvider {
    static let additionalPadding: CGFloat = 16.0
    
    static var previews: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                VStack(spacing: 24.0) {
                    ExpandableEntryView(entry: ExpandableEntryData.sample(), geometry: geometry, additionalOffset: additionalPadding * 2.0)
                    ExpandableEntryView(entry: ExpandableEntryData.sample(), geometry: geometry, additionalOffset: additionalPadding * 2.0)
                }
                .padding(additionalPadding)
            }
        }
        .background(Rectangle().fill(Color( UIColor.withStyle(.background).cgColor)), alignment: .center)
        .clipped()
    }
}

private extension ExpandableEntryData {
    static func sample() -> ExpandableEntryData {
        ExpandableEntryData(title: "An extraordinarily longer title, just to make things a little bit spicier. Everybody loves spices, at least a spice, at least they like like, or is indifferent to it. But does anybody hate all spices? I doubt it.", content: "A bit longer content, but not too much than the previous one.")
    }
}
