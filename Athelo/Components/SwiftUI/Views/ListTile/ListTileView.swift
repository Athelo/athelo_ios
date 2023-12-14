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
    let displaysBackgroundWaves: Bool
    let displaysNavigationChevron: Bool
    let forceTitleLeadingOffset: Bool
    
    init(data: ListTileDataProtocol, displaysBackgroundWaves: Bool = false, displaysNavigationChevron: Bool = false, forceTitleLeadingOffset: Bool = false) {
        self.data = data
        self.displaysBackgroundWaves = displaysBackgroundWaves
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
        .background(
            ZStack(alignment: .center) {
                Rectangle().fill(.white)
                
                if data.displaysBackgroundWaves {
                    WaveBackgroundView(offset: .init(x: 80.0, y: 20.0))
                        .opacity(0.2)
                        .mask(
                            LinearGradient(
                                stops: [
                                    .init(color: .clear, location: 0.0),
                                    .init(color: .black, location: 0.2),
                                    .init(color: .black, location: 1.0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }
        )
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
        ListTileView(data: .init(data: SampleData(listTileTitle: "Lump or area of thickening.", listTileImage: .image(.init(named: "symptomBladder")!)), displaysBackgroundWaves: true, displaysNavigationChevron: true, forceTitleLeadingOffset: true))
            .padding()
    }
}
