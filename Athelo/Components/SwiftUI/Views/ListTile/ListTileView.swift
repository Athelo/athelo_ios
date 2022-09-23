//
//  ListTileView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 18/07/2022.
//

import SwiftUI

protocol ListTileDataProtocol {
    var listTileTitle: String { get }
    var listTileImage: LoadableImageData? { get }
}

struct ListTileData {
    let data: ListTileDataProtocol
    let displaysNavigationChevron: Bool
    var forceTitleLeadingOffset: Bool
    
    init(data: ListTileDataProtocol, displaysNavigationChevron: Bool = false, forceTitleLeadingOffset: Bool = false) {
        self.data = data
        self.displaysNavigationChevron = displaysNavigationChevron
        self.forceTitleLeadingOffset = forceTitleLeadingOffset
    }
}

struct ListTileView: View {
    let data: ListTileData
    
    var body: some View {
        HStack(alignment: .center, spacing: 16.0) {
            if let listTileImage = data.data.listTileImage {
                StyledImageView(imageData: listTileImage, contentMode: .scaleAspectFit)
                    .frame(width: 24.0, height: 24.0, alignment: .center)
            } else if data.forceTitleLeadingOffset {
                Spacer(minLength: 24.0)
            }
            
            StyledText(data.data.listTileTitle,
                       textStyle: .button,
                       colorStyle: .gray,
                       extending: true,
                       alignment: .leading)
            
            if data.displaysNavigationChevron {
                Image("arrowRight")
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24.0, height: 24.0, alignment: .center)
            }
        }
        .padding(16.0)
        .frame(minHeight: 72.0, alignment: .center)
        .background(Rectangle().fill(.white))
        .cornerRadius(20.0)
        .styledShadow()
    }
}

struct ListTileView_Previews: PreviewProvider {
    private struct SampleData: ListTileDataProtocol {
        let listTileTitle: String
        let listTileImage: LoadableImageData?
    }
    
    static var previews: some View {
        ListTileView(data: .init(data: SampleData(listTileTitle: "Lump or area of thickening, also, more lines of text :) And more! And more! Please expand! Thank you :)", listTileImage: .image(.init(named: "symptomBladder")!)), displaysNavigationChevron: true, forceTitleLeadingOffset: true))
            .padding()
    }
}
