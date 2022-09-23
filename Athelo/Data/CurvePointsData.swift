//
//  CurvePointsData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 23/08/2022.
//

import Accelerate
import Foundation
import UIKit

struct CurvePointsData {
    struct Point {
        let x: Double
        let y: Double
    }
    
    let xValues: [Double]
    let yValues: [Double]
    
    init(xValues: [Double], yValues: [Double]) {
        self.xValues = xValues
        self.yValues = yValues
    }
    
    init(xValues: [CGFloat], yValues: [CGFloat]) {
        self.xValues = xValues.map({ CGFloat($0) })
        self.yValues = yValues.map({ CGFloat($0) })
    }
    
    func points() -> [Point] {
        guard !xValues.isEmpty, xValues.count == yValues.count else {
            return []
        }
        
        var points: [Point] = []
        for idx in 0..<xValues.count {
            let xValue = xValues[idx]
            let yValue = yValues[idx]
            
            points.append(.init(x: xValue, y: yValue))
        }
        
        return points
    }
    
    // Approach based on:
    //  - https://qroph.github.io/2018/07/30/smooth-paths-using-catmull-rom-splines.html
    //  - https://en.wikipedia.org/wiki/Centripetal_Catmull–Rom_spline
    func catmullRomPoints(alpha alphaVal: Double = 0.5, tension tensionVal: Double = 0.0, granularityPoints: Int = 10) -> [CGPoint] {
        var points = points().map({ CGPoint(x: $0.x, y: $0.y) })
        guard points.count >= 2 else {
            return []
        }
        
        guard let xMin = xValues.min(),
              let xMax = xValues.max() else {
            return []
        }
        
        var granularityPointsPool = max(granularityPoints, points.count * 2)
        let granularityUnitValue = (xMax - xMin) / Double(granularityPointsPool)
        
        let firstPoint = CGPoint(
            x: points.first!.x - 1.0,
            y: points.first!.y
        )
        let lastPoint = CGPoint(
            x: points.last!.x + 1.0,
            y: points.last!.y
        )
        
        points.insert(firstPoint, at: 0)
        points.append(lastPoint)
        
        let alpha: CGFloat = max(0.0, min(1.0, alphaVal))
        let tension: CGFloat = max(0.0, min(1.0, tensionVal))
        
        var splinePoints: [CGPoint] = []
        
        for idx in 1..<points.count - 2 {
            let p0 = points[idx - 1]
            let p1 = points[idx]
            let p2 = points[idx + 1]
            let p3 = points[idx + 2]
            
            let t0: CGFloat = 0.0;
            let t1 = t0 + pow(p0.distance(to: p1), alpha)
            let t2 = t1 + pow(p1.distance(to: p2), alpha)
            let t3 = t2 + pow(p2.distance(to: p3), alpha)
            
            let m1 = CGPoint(
                x: (1.0 - tension) * (t2 - t1) * ((p1.x - p0.x) / (t1 - t0) - (p2.x - p0.x) / (t2 - t0) + (p2.x - p1.x) / (t2 - t1)),
                y: (1.0 - tension) * (t2 - t1) * ((p1.y - p0.y) / (t1 - t0) - (p2.y - p0.y) / (t2 - t0) + (p2.y - p1.y) / (t2 - t1))
            )
            let m2 = CGPoint(
                x: (1.0 - tension) * (t2 - t1) * ((p2.x - p1.x) / (t2 - t1) - (p3.x - p1.x) / (t3 - t1) + (p3.x - p2.x) / (t3 - t2)),
                y: (1.0 - tension) * (t2 - t1) * ((p2.y - p1.y) / (t2 - t1) - (p3.y - p1.y) / (t3 - t1) + (p3.y - p2.y) / (t3 - t2))
            )
            
            let s0 = CGPoint(
                x: 2.0 * (p1.x - p2.x) + m1.x + m2.x,
                y: 2.0 * (p1.y - p2.y) + m1.y + m2.y
            )
            let s1 = CGPoint(
                x: -3.0 * (p1.x - p2.x) - 2.0 * m1.x - m2.x,
                y: -3.0 * (p1.y - p2.y) - 2.0 * m1.y - m2.y
            )
            let s2 = m1
            let s3 = p1
            
            var granularityPoints = max(4, Int((abs(p2.x - p1.x) / granularityUnitValue).rounded(.down)))
            if idx == points.count - 3 {
                granularityPoints = max(granularityPoints, granularityPointsPool)
            }
            
            granularityPointsPool -= granularityPoints
            
            for step in 1...granularityPoints {
                let stepCoefficient = CGFloat(step) / CGFloat(granularityPoints)
                
                let candidate = CGPoint(
                    x: s0.x * pow(stepCoefficient, 3.0) + s1.x * pow(stepCoefficient, 2.0) + s2.x * stepCoefficient + s3.x,
                    y: s0.y * pow(stepCoefficient, 3.0) + s1.y * pow(stepCoefficient, 2.0) + s2.y * stepCoefficient + s3.y
                )
                
                if let lastPoint = splinePoints.last {
                    if candidate.x != lastPoint.x {
                        splinePoints.append(candidate)
                    }
                } else {
                    splinePoints.append(candidate)
                }
            }
        }
        
        return splinePoints.sorted(by: \.x)
    }
}
