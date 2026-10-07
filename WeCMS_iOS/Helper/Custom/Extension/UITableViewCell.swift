//
//  TableViewCell.swift
//  WeCMS_iOS
//
//  Created by Bong Kokkheang on 4/4/23.
//

import Foundation

extension UITableViewCell {
    
    var getVCFromTVC : UIViewController? {
        return ((self.superview as? UITableView)?.delegate as? UIViewController)
    }
    
}
