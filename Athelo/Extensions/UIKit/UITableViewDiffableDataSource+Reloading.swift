//
//  UITableViewDiffableDataSource+Reloading.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 30/05/2022.
//

import UIKit

extension UITableViewDiffableDataSource {
    /// Creates in-place copy of current snapshot, applying `reloadItems` operation on selected item identifiers and instantly applies that snapshot.
    ///
    /// - Parameter identifiers: Identifiers of items to be relaoded.
    func reloadRows(for identifiers: [ItemIdentifierType], animated: Bool = false) {
        var snapshot = snapshot()
        
        guard Set(identifiers).isSubset(of: Set(snapshot.itemIdentifiers)) else {
            return
        }
        
        snapshot.reloadItems(identifiers)

        apply(snapshot, animatingDifferences: animated)
    }

    /// Creates in-place copy of current snapshot, applying `reloadSection` operation on selected section identifiers and instantly applies that snapshot.
    ///
    /// - Parameter identifiers: Identifiers of sections to be relaoded.
    func reloadSections(for identifiers: [SectionIdentifierType], animated: Bool = false) {
        var snapshot = snapshot()
        
        guard Set(identifiers).isSubset(of: Set(snapshot.sectionIdentifiers)) else {
            return
        }
        
        snapshot.reloadSections(identifiers)

        apply(snapshot, animatingDifferences: false)
    }
}
