//
//  Cell+convenience.swift
//  SmartHome
//
//  Created by Roland Tolnay on 16/07/2018.
//

import UIKit

extension UITableView {
  
  func register<T>(cell: T.Type) where T: UITableViewCell {

    let nib = UINib(nibName: "\(cell.self)", bundle: Bundle(for: T.self))
    register(nib, forCellReuseIdentifier: cell.identifier)
  }
  
  func dequeueReusableCell<T: UITableViewCell>(with cell: T.Type) -> T? {
    
    return dequeueReusableCell(withIdentifier: cell.identifier) as? T
  }
}

extension UITableViewCell {
  
  fileprivate static var identifier: String {
    
    return "\(self)"
  }
}

extension UICollectionView {
  
  func dequeueReusableCell<T: UICollectionViewCell>(with cell: T.Type, for indexPath: IndexPath) -> T? {
    
    return dequeueReusableCell(withReuseIdentifier: cell.identifier, for: indexPath) as? T
  }
}

extension UICollectionViewCell {
  
  fileprivate static var identifier: String {
    
    return "\(self)"
  }
}
