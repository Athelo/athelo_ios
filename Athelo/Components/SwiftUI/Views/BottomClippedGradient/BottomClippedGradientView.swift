//
//  BottomClippedGradientView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 24/06/2022.
//

import SwiftUI

struct BottomClippedGradientViewImageData {
    let image: UIImage
    let shouldClip: Bool
    let yOffset: CGFloat
}

struct BottomClippedGradientView: View {
    typealias ImageData = BottomClippedGradientViewImageData
    
    private let color: CGColor
    private let imageData: ImageData?
    
    init(color: CGColor? = nil, imageData: BottomClippedGradientViewImageData? = nil) {
        self.color = color ?? UIColor.withStyle(.greenB5DE71).cgColor
        self.imageData = imageData
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                LinearGradient(
                    stops:
                        [
                            .init(color: Color(color), location: 0.0),
                            .init(color: .white, location: 0.0),
                            .init(color: Color(color), location: 1.0)
                        ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(clippingCurve(within: geometry))
            }
            .background(Rectangle().fill(.clear))
            .ignoresSafeArea(.all, edges: [.top])
            
            if let imageData = imageData {
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(uiImage: imageData.image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: min(imageData.image.size.width, geometry.size.width - 32.0), alignment: .center)
                            Spacer()
                        }
                    }
                    .offset(.init(width: 0.0, height: imageData.yOffset))
                    .padding([.top], -imageData.yOffset)
                    .clipShape(clippingCurve(within: geometry, condition: imageData.shouldClip))
                }
            }
        }
    }
}

private extension View {
    func clippingCurve(within geometry: GeometryProxy, condition: Bool = true) -> some Shape {
        if condition {
            return Path { path in
                let ratio = max(0.0, min(180.0, geometry.size.height) / 180.0)
                
                path.move(to: .zero)
                path.addLine(to: .init(x: 0.0, y: geometry.size.height - (60.0 * ratio)))
                path.addCurve(
                    to: .init(x: geometry.size.width, y: geometry.size.height - (180.0 * ratio)),
                    control1: .init(x: geometry.size.width / 2.0, y: geometry.size.height + (45.0 * ratio)),
                    control2: .init(x: geometry.size.width * 0.8, y: geometry.size.height))
                path.addLine(to: .init(x: geometry.size.width, y: 0.0))
                path.closeSubpath()
            }
        } else {
            return Path { path in
                path.addRect(.init(origin: .zero, size: geometry.size))
            }
        }
    }
}

struct BottomClippedGradientView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Rectangle()
                .fill(.white)
            
            BottomClippedGradientView(imageData: .init(image: UIImage(named: "womanYogaPose")!, shouldClip: false, yOffset: -16.0))
        }
    }
}
