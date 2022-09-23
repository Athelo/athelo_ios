//
//  WatchEntryView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 05/07/2022.
//

import SwiftUI

struct WatchEntryView: View {
    let watchData: DeviceData
    
    private var checkmarkColor: UIColor {
        .withStyle(watchData.connected ? .purple623E61 : .gray)
    }
    
    private var watchImageName: String {
        "watch\(watchData.connected ? "Connected" : "Disconnected")"
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 32.0) {
            ZStack {
                Image(uiImage: UIImage(named: "watchDisconnected")!)
                    .opacity(watchData.connected ? 0.0 : 1.0)
                
                Image(uiImage: UIImage(named: "watchConnected")!)
                    .opacity(watchData.connected ? 1.0 : 0.0)
            }
            
            StyledText("Connect to \(watchData.type.name)",
                       textStyle: .body,
                       colorStyle: .gray,
                       alignment: .leading
            )
            
            ZStack {
                Rectangle()
                    .fill(Color(checkmarkColor.cgColor))
                
                Image(uiImage: UIImage(named: "checkmark")!.withRenderingMode(.alwaysTemplate))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
                    .frame(width: 20.0, height: 20.0, alignment: .center)
                    .opacity(watchData.connected ? 1.0 : 0.0)
            }
            .frame(width: 24.0, height: 24.0, alignment: .center)
            .roundedCorners(radius: 4.0)
        }
        .transition(.opacity)
        .padding(16.0)
        .background(
            Rectangle()
                .fill(.white)
        )
        .roundedCorners(radius: 30.0)
        .styledShadow()
    }
}

struct WatchEntryView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Rectangle()
                .fill(Color(UIColor.withStyle(.background).cgColor))
            
            VStack {
                WatchEntryView(watchData: .init(type: .fitbit, connected: true))
                    .padding(16.0)
            }
        }
    }
}
