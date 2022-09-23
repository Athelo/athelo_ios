//
//  UIKit+Reusable.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 30/05/2022.
//

import UIKit

protocol ReusableView {
    static var nib: UINib { get }
    static var identifier: String { get }
}

extension ReusableView {
    static var nib: UINib {
        UINib(nibName: identifier, bundle: Bundle.main)
    }

    static var identifier: String {
        String(describing: self)
    }
}

extension UIView: ReusableView {
    /* ... */
}

extension ReusableView where Self: UIView {
    static func instantiate(owner: Any? = nil, options: [UINib.OptionsKey: Any]? = nil) -> Self {
        guard let view = Bundle.main.loadNibNamed(Self.identifier, owner: owner, options: options)?.first as? Self else {
            fatalError("Could not instantiate an instance of \(Self.identifier).")
        }

        return view
    }
}

protocol ConfigurableCell: ReusableView {
    associatedtype DataType

    func configure(_ item: DataType, indexPath: IndexPath)
}

extension UITableView {
    func register<T: UITableViewCell>(_: T.Type) {
        register(T.self, forCellReuseIdentifier: T.identifier)
        register(T.nib, forCellReuseIdentifier: T.identifier)
    }

    func register<T: UITableViewCell>(cellTypes: [T.Type]) {
        cellTypes.forEach({ register($0) })
    }

    func registerHeader<T: UITableViewHeaderFooterView>(_: T.Type) {
        register(T.self, forHeaderFooterViewReuseIdentifier: T.identifier)
        register(T.nib, forHeaderFooterViewReuseIdentifier: T.identifier)
    }

    func dequeueReusableCell<T: UITableViewCell>(indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: T.identifier) as! T
    }

    func dequeueReusableCell<T: UITableViewCell>(withClass name: T.Type) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.identifier) as? T else {
            fatalError("Couldn't find UITableViewCell for \(T.identifier)")
        }

        return cell
    }

    func dequeueReusableCell<T: UITableViewCell>(withClass name: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as? T else {
            fatalError("Couldn't find UITableViewCell for \(T.identifier)")
        }

        return cell
    }

    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(withClass name: T.Type) -> T {
        guard let headerFooterView = dequeueReusableHeaderFooterView(withIdentifier: T.identifier) as? T else {
            fatalError("Couldn't find UITableViewHeaderFooterView for \(T.identifier)")
        }

        return headerFooterView
    }
}

extension UICollectionView {
    func register<T: UICollectionViewCell>(_: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.identifier)
        register(T.nib, forCellWithReuseIdentifier: T.identifier)
    }

    func registerFooter<T: UICollectionReusableView>(_: T.Type) {
        register(T.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: T.identifier)
        register(T.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: T.identifier)
    }

    func registerHeader<T: UICollectionReusableView>(_: T.Type) {
        register(T.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.identifier)
        register(T.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.identifier)
    }
    
    func registerSupplementaryView<T: UICollectionReusableView>(_: T.Type) {
        register(T.self, forSupplementaryViewOfKind: T.identifier, withReuseIdentifier: T.identifier)
        register(T.nib, forSupplementaryViewOfKind: T.identifier, withReuseIdentifier: T.identifier)
    }

    func dequeueReusableCell<T: UICollectionViewCell>(indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as! T
    }

    func dequeueReusableCell<T: UICollectionViewCell>(withClass name: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T else {
            fatalError("Couldn't find UICollectionViewCell for \(T.identifier)")
        }
        return cell
    }

    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind: String, withClass name: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.identifier, for: indexPath) as? T else {
            fatalError("Couldn't find UICollectionReusableView for \(T.identifier)")
        }
        return cell
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofClass className: T.Type, for indexPath: IndexPath) -> T {
        dequeueReusableSupplementaryView(ofKind: T.identifier, withClass: className, for: indexPath)
    }
}
