//
//  ListInputTableViewCell.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 06/06/2022.
//

import UIKit

protocol ListInputCellItemData {
    var listInputItemID: Int { get }
    var listInputItemName: String { get }
}

final class ListInputTableViewCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet private weak var imageViewCheckmark: UIImageView!
    @IBOutlet private weak var labelItemName: UILabel!
    
    // MARK: - View lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureOwnView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        imageViewCheckmark.isHidden = !selected
    }
    
    // MARK: - Configuration
    private func configure() {
        configureOwnView()
    }
    
    private func configureOwnView() {
        selectionStyle = .none
    }
}

// MARK: - Protocol conformance
// MARK: ConfigurableCell
extension ListInputTableViewCell: ConfigurableCell {
    typealias DataType = ListInputCellItemData
    
    func configure(_ item: DataType, indexPath: IndexPath) {
        labelItemName.text = item.listInputItemName
    }
}
