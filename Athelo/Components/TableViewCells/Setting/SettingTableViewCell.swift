//
//  SettingTableViewCell.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 21/07/2022.
//

import UIKit

typealias SettingCellConfigurationData = SettingTableViewCell.ConfigurationData

protocol SettingTableViewCellDelegate: AnyObject {
    func settingTableViewCell(_ cell: SettingTableViewCell, updatedState state: Bool)
}

final class SettingTableViewCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet private weak var labelOption: UILabel!
    @IBOutlet private weak var switchOptionState: UISwitch!
    
    // MARK: - Properties
    private weak var delegate: SettingTableViewCellDelegate?
    
    // MARK: - Public API
    func assignDelegate(_ delegate: SettingTableViewCellDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Actions
    @IBAction private func optionStateSwitchChangedValue(_ sender: Any) {
        delegate?.settingTableViewCell(self, updatedState: switchOptionState.isOn)
    }
}

// MARK: - Protocol conformance
// MARK: ConfigurableCell
extension SettingTableViewCell: ConfigurableCell {
    struct ConfigurationData {
        let option: SettingOption
        let optionState: Bool?
        
        init(option: SettingOption, optionState: Bool? = nil) {
            self.option = option
            self.optionState = optionState
        }
    }
    
    func configure(_ item: SettingCellConfigurationData, indexPath: IndexPath) {
        labelOption.text = item.option.title
        
        if let optionState = item.optionState {
            switchOptionState.isOn = optionState
            switchOptionState.isHidden = false
        } else {
            switchOptionState.isHidden = true
        }
    }
}
