//
//  TableViewCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Bong Kokkheang on 4/4/23.
//

import Foundation

extension UITableViewCell {
    
    var getVCFromTVC : UIViewController? {
        return ((self.superview as? UITableView)?.delegate as? UIViewController)
    }
    
}
