//
//  LinearGraphView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 09/08/2022.
//

import SpriteKit
import SwiftUI

struct LinearGraphView: View {
    @ObservedObject var model: LinearChartModel
    
    @State private var isDragging: Bool = false
    @State private var selectedPoint: GraphLinePointData?
    
    @State private var cachedSplinePoints: [CGPoint]?
    @State private var dotPosition: CGPoint = .zero
    @State private var overlayPosition: CGPoint = .zero
    
    @State private var selectedPointLabel: String?
    @State private var selectedPointSecondaryLabel: String?
    
    private let horizontalGridOffset: CGFloat = 8.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            if let legendTitle = model.legendLabel, !legendTitle.isEmpty {
                StyledText(legendTitle,
                           textStyle: .legend,
                           colorStyle: .lightGray,
                           alignment: .leading)
                .padding(.bottom, 8.0)
            }
            
            HStack(spacing: 0.0) {
                GraphVerticalLegendView()
                    .frame(width: model.legendWidth, alignment: .center)
                    .environmentObject(model.verticalItemsModel)
                    .animation(.default)
                
                ZStack {
                    GraphVerticalGridView(
                        columnCount: $model.columnCount,
                        drawingRule: $model.gridDrawingRule,
                        gridHorizontalOffset: .constant(horizontalGridOffset),
                        spread: .absolute
                    )
                    
                    if model.displaysHorizontalGrid {
                        GraphHorizontalGridView()
                            .environmentObject(model.verticalItemsModel)
                    }
                    
                    HStack {
                        Spacer(minLength: horizontalGridOffset)
                        
                        ZStack {
                            GeometryReader { geometry in
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
                            
                            ZStack {
                                Circle()
                                    .fill(Color(UIColor.withStyle(.white).cgColor))
                                
                                Circle()
                                    .fill(Color(UIColor.withStyle(.lightOlivaceous).cgColor))
                                    .frame(width: 6.0, height: 6.0, alignment: .center)
                                    .position(x: 8.0, y: 8.0)
                            }
                            .frame(width: 16.0, height: 16.0, alignment: .center)
                            .styledBackground(.clear)
                            .position(x: dotPosition.x, y: dotPosition.y)
                            .opacity(selectedPoint != nil ? 1.0 : 0.0)
                            .animation(.default)
                            
                            GraphSelectedItemInfoView(
                                label: $selectedPointLabel,
                                secondaryLabel: $selectedPointSecondaryLabel
                            )
                            .position(x: overlayPosition.x, y: overlayPosition.y)
                            .opacity(selectedPoint != nil ? 1.0 : 0.0)
                            .animation(.default)
                            
                            TapOverlayView(callback: { point, size in
                                handleTap(in: point, size: size)
                            }, dragStateCallback: { isDragging in
                                self.isDragging = isDragging
                            })
                        }
                        
                        Spacer(minLength: horizontalGridOffset)
                    }
                }
                .animation(.default, value: model.pointsData.dataPoints)
            }
            
            HStack(spacing: 0.0) {
                Spacer(minLength: model.legendWidth + horizontalGridOffset)
                
                GraphHorizontalLegendView(spread: .absolute)
                    .frame(height: 20.0, alignment: .top)
                    .environmentObject(model.horizontalItemsModel)
                    .animation(.default)
                
                Spacer(minLength: horizontalGridOffset)
            }
        }
        .onChange(of: model.pointsData.dataPoints) { newValue in
            cachedSplinePoints = nil
            selectedPoint = nil
        }
        .onChange(of: selectedPoint) { newValue in
            selectedPointLabel = newValue?.label
            selectedPointSecondaryLabel = newValue?.secondaryLabel
        }
    }
    
    @ViewBuilder
    private func shape(inside geometry: GeometryProxy, enclosing: Bool) -> some Shape {
        LineGraphShape(
            splines: cachedSplinePoints ?? splinePoints(definedBy: model.pointsData.dataPoints.map({ $0.toPoint }), inside: geometry.size, interpolationMode: .spline),
            enclosing: enclosing,
            geometry: geometry
        )
    }
    
    private func dataPoint(at point: CGPoint, in size: CGSize) -> (point: GraphLinePointData, position: CGPoint)? {
        let xRange = model.adjustedMinXDataValue...model.adjustedMaxXDataValue
        let yRange = model.adjustedMinYDataValue...model.adjustedMaxYDataValue
        
        let xDistance = xRange.upperBound - xRange.lowerBound
        let yDistance = yRange.upperBound - yRange.lowerBound
        
        var foundDataPoint: GraphLinePointData?
        var foundPosition: CGPoint?
        
        for dataPoint in model.pointsData.dataPoints {
            let xPosition = (dataPoint.x - xRange.lowerBound) / xDistance * size.width
            let yPostition = (yRange.upperBound - dataPoint.y) / yDistance * size.height
            let position = CGPoint(x: xPosition, y: yPostition)
            
            if let currentPosition = foundPosition {
                if point.distance(to: position) < point.distance(to: currentPosition) {
                    foundDataPoint = dataPoint
                    foundPosition = position
                }
            } else {
                foundDataPoint = dataPoint
                foundPosition = position
            }
        }
        
        guard let dataPoint = foundDataPoint,
              let position = foundPosition else {
            return nil
        }
        
        if !isDragging {
            let boundingRect = CGRect(
                x: point.x - size.width / 10.0,
                y: point.y - size.height / 10.0,
                width: size.width / 5.0,
                height: size.height / 5.0
            )
            
            if !boundingRect.contains(position) {
                return nil
            }
        }
        
        return (dataPoint, position)
    }
    
    private func handleTap(in point: CGPoint, size: CGSize) {
        let pointSearchResult = dataPoint(at: point, in: size)
        if isDragging, pointSearchResult == nil {
            return
        }
        
        selectedPoint = pointSearchResult?.point
        
        guard let selectedPoint = pointSearchResult?.point,
              let position = pointSearchResult?.position else {
            return
        }
        
        let overlaySize = GraphUtils.overlaySize(for: selectedPoint.label, secondaryLabel: selectedPoint.secondaryLabel)
        
        var targetCoordinates = position
        targetCoordinates.x = max(targetCoordinates.x - 10.0, min(targetCoordinates.x + 10.0, point.x))
        targetCoordinates.y -= overlaySize.height / 2.0
        targetCoordinates = GraphUtils.adjustOverlayCenterPoint(targetCoordinates, inside: size, overlaySize: overlaySize)
        
        let splinePoints = cachedSplinePoints ?? splinePoints(definedBy: model.pointsData.dataPoints.map({ $0.toPoint }), inside: size, interpolationMode: .spline)
        if cachedSplinePoints == nil {
            cachedSplinePoints = splinePoints
        }
        
        let allowedXDistance = size.width / 50.0
        var foundSplinePoint: CGPoint?
        
        for splinePoint in splinePoints {
            guard abs(splinePoint.x - position.x) <= allowedXDistance else {
                continue
            }
            
            if let currentX = foundSplinePoint?.x {
                if abs(splinePoint.x - point.x) < abs(currentX - point.x) {
                    foundSplinePoint = splinePoint
                }
            } else {
                foundSplinePoint = splinePoint
            }
        }
        
        dotPosition = foundSplinePoint ?? .zero
        
        let overlayRect = CGRect(
            x: targetCoordinates.x - overlaySize.width / 2.0,
            y: targetCoordinates.y - overlaySize.height / 2.0,
            width: overlaySize.width,
            height: overlaySize.height
        )
        
        if let dotPosition = foundSplinePoint, overlayRect.contains(dotPosition) {
            let targetY = dotPosition.y - (8.0 + overlayRect.size.height / 2.0)
            targetCoordinates.y = targetY
        }
        
        overlayPosition = targetCoordinates
    }
    
    private func splinePoints(definedBy points: [CGPoint], inside size: CGSize, interpolationMode: SKInterpolationMode) -> [CGPoint] {        
        var splines: [CGPoint] = []
        
        let xValues = points.map({ $0.x })
        var yValues = points.map({ $0.y })
        
        let yMin = model.adjustedMinYDataValue
        let yMax = model.adjustedMaxYDataValue
        
        let yDiff = yMax - yMin
        
        yValues = yValues.map({ (yMax - $0) / yDiff * size.height})
        
        guard var xMin = xValues.min(),
              var xMax = xValues.max() else {
            return splines
        }
        
        let adjustedXMin = model.adjustedMinXDataValue
        let adjustedXMax = model.adjustedMaxXDataValue
        let adjustedXDistance = adjustedXMax - adjustedXMin
        
        if xMin == xMax {
            let xValuesPerPixel = adjustedXDistance / size.width
            
            xMin = max(adjustedXMin, xMin - xValuesPerPixel * 2.5)
            xMax = min(adjustedXMax, xMax + xValuesPerPixel * 2.5)
        }
        
        let xDistance = xMax - xMin
        
        switch interpolationMode {
        case .spline:
            if points.count >= 2 {
                let curvePointsData = CurvePointsData(xValues: xValues, yValues: yValues)
                let smoothedSplines = curvePointsData.catmullRomPoints(granularityPoints: Int((size.width).rounded(.up)))

                for spline in smoothedSplines {
                    let splinePoint = CGPoint(x: (spline.x - adjustedXMin) / adjustedXDistance * size.width, y: spline.y)
                    splines.append(splinePoint)
                }
            } else {
                let sequence = SKKeyframeSequence(keyframeValues: yValues, times: xValues.map({ NSNumber(value: $0) }))
                sequence.interpolationMode = interpolationMode
                
                stride(from: xMin, to: xMax, by: xDistance / size.width).forEach({
                    let splinePoint = CGPoint(x: ($0 - adjustedXMin) / adjustedXDistance * size.width, y: sequence.sample(atTime: $0) as! CGFloat)
                    splines.append(splinePoint)
                })
                
                let endPoint = CGPoint(x: (xMax - adjustedXMin) / adjustedXDistance * size.width, y: sequence.sample(atTime: xMax) as! CGFloat)
                splines.append(endPoint)
            }
        case .linear, .step:
            fallthrough
        @unknown default:
            let sequence = SKKeyframeSequence(keyframeValues: yValues, times: xValues.map({ NSNumber(value: $0) }))
            sequence.interpolationMode = interpolationMode
            
            for xValue in xValues {
                let splinePoint = CGPoint(x: (xValue - adjustedXMin) / adjustedXDistance * size.width, y: sequence.sample(atTime: xValue) as! CGFloat)
                splines.append(splinePoint)
            }
        }
        
        return splines
    }
}

struct LinearGraphView_Previews: PreviewProvider {
    private static let model: LinearChartModel = {
        let model = LinearChartModel()
        
        model.updateLegendLabel(":)")
        model.displaysHorizontalGrid = true
        
        return model
    }()
    
    static var previews: some View {
        VStack {
            Button {
                let items = (2...Int.random(in: 5...9)).map({
                    GraphLinePointData(x: Double($0), y: Double(Int.random(in: 0...$0) * 10000))
                })
                let legend = items.map({ GraphLegendItemData(id: Int($0.x), name: "\(Int($0.x))") })
                
                model.updatePointsData(.init(dataPoints: items))
                model.updateHorizontalLegendItems(legend)
            } label: {
                Text("Randomize items!")
            }
            
            Divider()
            
            LinearGraphView(model: model)
                .padding(.horizontal, 8.0)
        }
    }
}
