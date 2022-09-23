//
//  SmallLineGraphView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 08/08/2022.
//

import SpriteKit
import SwiftUI

struct SmallLineGraphView: View {
    @EnvironmentObject var model: SmallLineGraphModel
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(UIColor.withStyle(.greenB5DE71).cgColor).opacity(0.34),
                            Color(UIColor.withStyle(.olivaceous).cgColor).opacity(0.00)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(shape(inside: geometry, enclosing: true))
                    
                    shape(inside: geometry, enclosing: false)
                        .stroke(Color(UIColor.withStyle(.lightOlivaceous).cgColor), style: .init(lineWidth: 2.0, lineCap: .round, lineJoin: .round, miterLimit: 0.0, dash: [], dashPhase: 0.0))
                }
                .animation(.default, value: model.points)
            }
        }
    }
    
    @ViewBuilder
    private func shape(inside geometry: GeometryProxy, enclosing: Bool) -> some Shape {
        LineGraphShape(
            splines: splinePoints(definedBy: model.points.map({ $0.toPoint }), inside: geometry, interpolationMode: model.interpolationMode),
            enclosing: enclosing,
            geometry: geometry
        )
    }
    
    private func splinePoints(definedBy points: [CGPoint], inside geometry: GeometryProxy, interpolationMode: SKInterpolationMode) -> [CGPoint] {
        var splines: [CGPoint] = []
        
        let xValues = points.map({ $0.x })
        var yValues = points.map({ $0.y })
        
        guard var yMin = yValues.min(),
              var yMax = yValues.max() else {
            return splines
        }
        
        var yDiff = yMax - yMin
        
        if yDiff.isZero {
            yMax += 1.0
            yMin -= 0.5
        } else {
            yMax += yDiff / 5.0
            yMin -= yDiff / 5.0
        }
        
        yDiff = yMax - yMin
        
        yValues = yValues.map({ (yMax - $0) / yDiff * geometry.size.height})
        
        guard let minX = xValues.min(),
              let maxX = xValues.max() else {
            return splines
        }
        
        let sequence = SKKeyframeSequence(keyframeValues: yValues, times: xValues.map({ NSNumber(value: $0) }))
        sequence.interpolationMode = interpolationMode
        
        let xDistance = maxX - minX
        switch interpolationMode {
        case .spline:
            if points.count >= 2 {
                let curvePointsData = CurvePointsData(xValues: xValues, yValues: yValues)
                let smoothedSplines = curvePointsData.catmullRomPoints(granularityPoints: Int((geometry.size.width).rounded(.up)))

                for spline in smoothedSplines {
                    let splinePoint = CGPoint(x: spline.x / xDistance * geometry.size.width, y: spline.y)
                    splines.append(splinePoint)
                }
            } else {
                stride(from: minX, to: maxX, by: xDistance / geometry.size.width).forEach({
                    let splinePoint = CGPoint(x: $0 / xDistance * geometry.size.width, y: sequence.sample(atTime: $0) as! CGFloat)
                    splines.append(splinePoint)
                })
                
                let endPoint = CGPoint(x: maxX / xDistance * geometry.size.width, y: sequence.sample(atTime: maxX) as! CGFloat)
                splines.append(endPoint)
            }
        case .linear, .step:
            fallthrough
        @unknown default:
            for xValue in xValues {
                let splinePoint = CGPoint(x: xValue / xDistance * geometry.size.width, y: sequence.sample(atTime: xValue) as! CGFloat)
                splines.append(splinePoint)
            }
        }
        
        return splines
    }
}

struct SmallLineGraphView_Previews: PreviewProvider {
    private static let model = SmallLineGraphModel(points: randomizedPoints(), interpolationMode: .spline)
    
    private static func randomizedPoints() -> [GraphLinePointData] {
        (0...10).map({
            .init(x: Double($0) / 10.0, y: Double(Int.random(in: 0...3)))
        })
    }
    
    static var previews: some View {
        VStack {
            SmallLineGraphView()
                .environmentObject(model)
            
            Button {
                model.updatePoints(randomizedPoints())
            } label: {
                Text("Randomize!")
            }
        }
    }
}


