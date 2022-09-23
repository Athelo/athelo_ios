//
//  CircularProgressView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 26/07/2022.
//

import SwiftUI

final class CircularProgressModel: ObservableObject {
    @Published private(set) var progress: CGFloat
    @Published private(set) var text: String?
    
    init(progress: CGFloat = 0.0, text: String? = nil) {
        self.progress = progress
        self.text = text
    }
    
    func updateProgress(_ progress: CGFloat, text: String?) {
        self.progress = progress
        self.text = text
    }
}

struct CircularProgressView: View {
    @EnvironmentObject var model: CircularProgressModel
    
    private let rimWidth: CGFloat = 14.0
    
    private var text: String? {
        model.text
    }
    
    private var progress: CGFloat {
        model.progress
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0.0) {
            ZStack {
                if let text = text {
                    GeometryReader { geometry in
                        StyledText(text,
                                   textStyle: .subheading,
                                   colorStyle: .lightOlivaceous)
                        .position(x: geometry.size.width / 2.0, y: geometry.size.height / 2.0)
                        .frame(maxWidth: min(geometry.size.width, geometry.size.height) - rimWidth * 2.0, maxHeight: min(geometry.size.width, geometry.size.height) - rimWidth * 2.0)
                    }
                }
                
                GeometryReader { geometry in
                    Path { path in
                        let center = CGPoint(x: geometry.size.width / 2.0, y: geometry.size.height / 2.0)
                        let radius = min(geometry.size.width, geometry.size.height) / 2.0 - (rimWidth / 2.0)
                        
                        path.addArc(center: center, radius: radius, startAngle: .degrees(0.0), endAngle: .degrees(360.0), clockwise: false)
                    }
                    .rotation(.degrees(-90.0))
                    .stroke(Color(UIColor.withStyle(.lightOlivaceous).cgColor).opacity(0.2), style: .init(lineWidth: rimWidth, lineCap: .round, lineJoin: .round, miterLimit: 1.0, dash: [], dashPhase: 0.0))
                    .animation(.spring(), value: progress)
                }
                
                GeometryReader { geometry in
                    Path { path in
                        let center = CGPoint(x: geometry.size.width / 2.0, y: geometry.size.height / 2.0)
                        let radius = min(geometry.size.width, geometry.size.height) / 2.0 - (rimWidth / 2.0)
                        
                        path.addArc(center: center, radius: radius, startAngle: .degrees(0.0), endAngle: .degrees(360.0), clockwise: false)
                    }
                    .trim(from: 0.0, to: progress)
                    .rotation(.degrees(-90.0))
                    .stroke(Color(UIColor.withStyle(.lightOlivaceous).cgColor), style: .init(lineWidth: rimWidth, lineCap: .round, lineJoin: .round, miterLimit: 1.0, dash: [], dashPhase: 0.0))
                    .animation(.spring(), value: progress)
                }
            }
        }
    }
}

struct CircularProgressView_Previews: PreviewProvider {
    private static let model = CircularProgressModel(progress: 0.499, text: "Yes!")
    
    static var previews: some View {
        CircularProgressView()
            .background(Rectangle().fill(Color.white))
            .environmentObject(model)
    }
}
