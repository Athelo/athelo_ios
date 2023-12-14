//
//  SelectedWardModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/03/2023.
//

import Foundation

final class SelectedWardModel: ObservableObject {
    @Published private(set) var selectedWard: ContactData?
    
    func updateWard(_ selectedWard: ContactData?) {
        self.selectedWard = selectedWard
    }
}
