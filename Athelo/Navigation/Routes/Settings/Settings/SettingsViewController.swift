//
//  SettingsViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 21/07/2022.
//

import Combine
import UIKit

final class SettingsViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var labelVersion: UILabel!
    @IBOutlet private weak var tableViewSettings: UITableView!
    
    // MARK: - Properties
    private let viewModel = SettingsViewModel()
    private var router: SettingsRouter?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        sink()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureOwnView()
        configureSettingsTableView()
        configureVersionLabel()
    }
    
    private func configureOwnView() {
        title = "navigation.settings".localized()
    }
    
    private func configureSettingsTableView() {
        tableViewSettings.register(SettingTableViewCell.self)
        
        tableViewSettings.contentInset = .init(top: 24.0, bottom: 16.0)
        
        tableViewSettings.dataSource = self
        tableViewSettings.delegate = self
    }
    
    private func configureVersionLabel() {
        var versionText = "v. \(Bundle.main.appBuild) (\(Bundle.main.appVersion))"
        if let identifier: String = try? ConfigurationReader.configurationValue(for: .apiIdentifier),
           identifier.contains("QA") {
            versionText += " [QA]"
        }
        
        labelVersion.text = versionText
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoViewModel()
    }
    
    private func sinkIntoViewModel() {
        bindToViewModel(viewModel, cancellables: &cancellables)
        
        viewModel.optionsUpdatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.tableViewSettings.reloadData()
            }.store(in: &cancellables)
    }
}

// MARK: - Protocol conformance
// MARK: Navigable
extension SettingsViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .settings
    }
}

// MARK: Routable
extension SettingsViewController: Routable {
    func assignRouter(_ router: SettingsRouter) {
        self.router = router
    }
}

// MARK: SettingTableViewCellDelegate
extension SettingsViewController: SettingTableViewCellDelegate {
    func settingTableViewCell(_ cell: SettingTableViewCell, updatedState state: Bool) {
        guard let cellIndexPath = tableViewSettings.indexPath(for: cell) else {
            return
        }
        
        debugPrint(#fileID, #function, cellIndexPath, state)
    }
}

// MARK: UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfOptions()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: SettingTableViewCell.self, for: indexPath)
        
        cell.assignDelegate(self)
        if let data = viewModel.configurationData(at: indexPath) {
            cell.configure(data, indexPath: indexPath)
        }
        
        return cell
    }
}

// MARK: UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let action = viewModel.action(at: indexPath) else {
            return
        }
        
        switch action {
        case .displayLegal(let configurationData):
            router?.navigateToLegal(using: configurationData)
        case .displayPersonalInformation:
            router?.navigateToPersonalInformation()
        }
    }
}
