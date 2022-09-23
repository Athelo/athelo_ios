//
//  WatchListView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 05/07/2022.
//

import SwiftUI

protocol WatchListViewDelegate: AnyObject {
    func watchListViewSelectedDevice(_ deviceData: DeviceData)
}

struct WatchListView: View {
    @ObservedObject private(set) var model: WatchListModel
    private weak var delegate: WatchListViewDelegate?
    
    init(model: WatchListModel, delegate: WatchListViewDelegate? = nil) {
        self.model = model
        self.delegate = delegate
    }
    
    var body: some View {
        ScrollView(.vertical) {
            Spacer(minLength: 24.0)
            
            VStack(alignment: .center, spacing: 16.0) {
                StyledText("watch.list.header".localized(),
                           textStyle: .intro,
                           colorStyle: .purple623E61,
                           alignment: .center)
                
                StyledText("watch.list.subheader".localized(),
                           textStyle: .body,
                           colorStyle: .gray,
                           alignment: .center)
            }
            .padding([.leading, .trailing], 16.0)
            
            Spacer(minLength: 24.0)
            
            VStack(alignment: .center, spacing: 16.0) {
                ForEach(model.devices) { device in
                    WatchEntryView(watchData: device)
                        .transition(.opacity.combined(with: .scale))
                        .animation(.default.speed(0.75))
                        .onTapGesture {
                            delegate?.watchListViewSelectedDevice(device)
                        }
                }
            }
            .padding([.leading, .trailing], 16.0)
            .animation(.default, value: model.devices)
            
            Spacer(minLength: 24.0)
        }
        .animation(.default)
    }
}

struct WatchListView_Previews: PreviewProvider {
    private static let model = WatchListModel(devices: [])
    
    static var previews: some View {
        VStack {
            Button {
                let newEntry = DeviceData(type: DeviceType.allCases.randomElement()!, connected: Bool.random())
                model.updateDevice(newEntry)
            } label: {
                Text("Switch Fitbit item connection status")
            }
            
            Divider()
            
            WatchListView(model: model)
        }
    }
}
