//
//  LineGraphShape.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 08/08/2022.
//

import Foundation
import SwiftUI

// Based on: https://stackoverflow.com/questions/64157672/swiftui-line-graph-animation-using-vector-arithmetic
struct LineGraphShape: Shape {
    var splines: [CGPoint]
    var enclosing: Bool
    var geometry: GeometryProxy
    
    var animatableData: LineGraphVector {
        get { .init(points: splines.map { CGPoint.AnimatableData($0.x, $0.y) }) }
        set { splines = newValue.points.map { CGPoint(x: $0.first, y: $0.second) } }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            if !splines.isEmpty {
                let splinePoint = splines[0]
                if enclosing {
                    path.move(to: .init(x: splinePoint.x, y: geometry.size.height))
                }
                
                enclosing ? path.addLine(to: splinePoint) : path.move(to: splinePoint)
            }
            
            if splines.count > 1 {
                for splinePoint in splines.dropFirst() {
                    path.addLine(to: splinePoint)
                }
                
                if enclosing,
                   let lastSpline = splines.last {
                    path.addLine(to: .init(x: lastSpline.x, y: geometry.size.height))
                }
            }
        }
    }
}

extension LineGraphShape {
    struct LineGraphVector: VectorArithmetic {
        var points: [CGPoint.AnimatableData]
        
        static func + (lhs: LineGraphVector, rhs: LineGraphVector) -> LineGraphVector {
            return add(lhs: lhs, rhs: rhs, +)
        }
        
        static func - (lhs: LineGraphVector, rhs: LineGraphVector) -> LineGraphVector {
            return add(lhs: lhs, rhs: rhs, -)
        }
        
        static func add(lhs: LineGraphVector, rhs: LineGraphVector, _ sign: (CGFloat, CGFloat) -> CGFloat) -> LineGraphVector {
            let maxPoints = max(lhs.points.count, rhs.points.count)
            let leftIndices = lhs.points.indices
            let rightIndices = rhs.points.indices
            
            var newPoints: [CGPoint.AnimatableData] = []
            (0 ..< maxPoints).forEach { index in
                if leftIndices.contains(index) && rightIndices.contains(index) {
                    let lhsPoint = lhs.points[index]
                    let rhsPoint = rhs.points[index]
                    newPoints.append(
                        .init(
                            sign(lhsPoint.first, rhsPoint.first),
                            sign(lhsPoint.second, rhsPoint.second)
                        )
                    )
                } else if rightIndices.contains(index), let lastLeftPoint = lhs.points.last {
                    let rightPoint = rhs.points[index]
                    newPoints.append(
                        .init(
                            sign(lastLeftPoint.first, rightPoint.first),
                            sign(lastLeftPoint.second, rightPoint.second)
                        )
                    )
                } else if leftIndices.contains(index), let lastPoint = newPoints.last {
                    let leftPoint = lhs.points[index]
                    newPoints.append(
                        .init(
                            sign(lastPoint.first, leftPoint.first),
                            sign(lastPoint.second, leftPoint.second)
                        )
                    )
                }
            }
            
            return .init(points: newPoints)
        }
        
        mutating func scale(by rhs: Double) {
            points.indices.forEach { index in
                self.points[index].scale(by: rhs)
            }
        }
        
        var magnitudeSquared: Double {
            return 1.0
        }
        
        static var zero: LineGraphVector {
            return .init(points: [])
        }
    }
}
