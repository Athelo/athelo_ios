//
//  InvitationView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 02/09/2022.
//

import SwiftUI

struct InvitationView: View {
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    LinearGradient(
                        colors: [
                            Color(UIColor.withStyle(.greenB5DE71).cgColor).opacity(0.11),
                            Color(UIColor.withStyle(.greenB5DE71).cgColor).opacity(1.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .clipShape(clippingCurve(inside: geometry.size))
                    
                    VStack(alignment: .center) {
                        Rectangle()
                            .fill(.clear)
                            .frame(height: geometry.size.height * 0.215, alignment: .center)
                        
                        StyledImageView(
                            imageData: .image(.init(named: "sleepingMoon")!)
                        )
                        .frame(width: 112.0, height: 112.0, alignment: .center)
                        .styledBackground(.withStyle(.background))
                        .overlay(
                            RoundedRectangle(cornerRadius: 56.0)
                                .stroke(.white, lineWidth: 4.0)
                        )
                        .roundedCorners(radius: 56.0)
                        .styledShadow()
                        
                        Rectangle()
                            .fill(.clear)
                            .frame(height: 20.0, alignment: .center)
                        
                        VStack(spacing: 3.0) {
                            StyledText(
                                "Athena Smith",
                                textStyle: .headline20,
                                colorStyle: .black
                            )
                            
                            StyledText(
                                "invites you to join as caregiver",
                                textStyle: .body,
                                colorStyle: .gray
                            )
                        }
                        .padding(.horizontal, 24.0)
                    }
                    
                    VStack {
                        Spacer()
                        
                        Image("wavesBackground")
                    }
                }
            }
            .ignoresSafeArea()
            
            VStack(spacing: 16.0) {
                Spacer()
                
                StyledButtonView(
                    title: "Accept Invite",
                    style: .main,
                    tapHandler: {
                        
                    }
                )
                .frame(height: 52.0, alignment: .center)
                
                StyledButtonView(
                    title: "Cancel",
                    style: .secondary,
                    tapHandler: {
                        
                    }
                )
                .frame(height: 52.0, alignment: .center)
            }
            .padding(.horizontal, 16.0)
            .padding(.bottom, 16.0)
        }
    }
    
    private func clippingCurve(inside size: CGSize) -> some Shape {
        let points: [CGPoint] = [
            .init(x: 0.0, y: size.height * 0.18),
            .init(x: size.width * 0.095, y: size.height * 0.14),
            .init(x: size.width * 0.8, y: size.height * 0.42),
            .init(x: size.width, y: size.height * 0.38)
        ]
        
        let pointsData = CurvePointsData(
            xValues: points.map({ $0.x }),
            yValues: points.map({ $0.y })
        )
        
        let splinePoints = pointsData.catmullRomPoints(granularityPoints: Int(size.width.rounded(.up)))
        
        return Path { path in
            path.move(to: .zero)
            
            for splinePoint in splinePoints {
                path.addLine(to: splinePoint)
            }
            
            path.addLine(to: .init(x: size.width, y: 0.0))
            path.closeSubpath()
        }
    }
}

struct InvitationView_Previews: PreviewProvider {
    static var previews: some View {
        InvitationView()
    }
}
