//
//  WatchListModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 05/07/2022.
//

import Foundation

final class WatchListModel: ObservableObject {
    @Published private(set) var devices: [DeviceData]
    
    init(devices: [DeviceData]) {
        self.devices = devices
    }
    
    func updateDevice(_ device: DeviceData) {
        if let deviceIndex = devices.firstIndex(where: { $0.id == device.id }) {
            devices[deviceIndex] = device
        } else {
            devices.append(device)
        }
    }
    
    func updateEntries(_ devices: [DeviceData]) {
        self.devices = devices
    }
}
