//
//  ExpenseApprovalLayout.swift
//  WeCMS_iOS
//
//  Created by Bong Kokkheang on 25/1/24.
//

import Foundation
import UIKit

class ExpenseApprovalLayout {
    
    public static func statusLayout() -> NSCollectionLayoutSection {
        
        //reprsent cell
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(153)))
        //determine how items in a collection view are arranged
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),  heightDimension:  .estimated(153))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        return section
    }
    
    public static func amountLayout() -> NSCollectionLayoutSection {
        
        //reprsent cell
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(70)))
        //determine how items in a collection view are arranged
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),  heightDimension:  .estimated(70))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        return section
    }
    
    public static func descLayout() -> NSCollectionLayoutSection {
        
        //reprsent cell
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(62)))
        //determine how items in a collection view are arranged
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),  heightDimension:  .estimated(62))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0)
        return section
    }
    
    public static func expenseFileLayout(itemCount: Int) -> NSCollectionLayoutSection {
        
        //reprsent cell
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(66)))
        item.contentInsets.top = 10
        //determine how items in a collection view are arranged
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),  heightDimension:  .estimated(CGFloat(66 * itemCount )))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: itemCount)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        return section
    }
    
    public static func expenseImageLayout(itemCount: Int) -> NSCollectionLayoutSection {
        
        //reprsent cell
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(360)))
        item.contentInsets.top = 10
        //determine how items in a collection view are arranged
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),  heightDimension:  .estimated(CGFloat(360 * itemCount)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: itemCount)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 20, bottom: 0, trailing: 20)
        return section
    }
    
    public static func titleExpenseLayout() -> NSCollectionLayoutSection {
        
        //reprsent cell
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(83)))
        //determine how items in a collection view are arranged
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),  heightDimension:  .estimated(83))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 25, leading: 20, bottom: 0, trailing: 20)
        return section
    }
    
    public static func expenseListLayout(itemCount: Int) -> NSCollectionLayoutSection {
        
        //reprsent cell
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(93)))
        item.contentInsets.top = 10
        //determine how items in a collection view are arranged
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),  heightDimension:  .estimated(CGFloat(93 * itemCount)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: itemCount)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 20, bottom: 0, trailing: 20)
        return section
    }
    
    public static func expenseApproverLayout() -> NSCollectionLayoutSection {
        
        //reprsent cell
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(48)))
        //determine how items in a collection view are arranged
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),  heightDimension:  .estimated(48))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20)
        return section
    }
    
    public static func expenseUnderLineLayout() -> NSCollectionLayoutSection {
        
        //reprsent cell
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(10)))
        //determine how items in a collection view are arranged
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),  heightDimension:  .estimated(10))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        return section
    }
    
    public static func expenseSplitLineLayout() -> NSCollectionLayoutSection {
        
        //reprsent cell
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(5)))
        //determine how items in a collection view are arranged
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),  heightDimension:  .absolute(5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0)
        return section
    }
    
    public static func commentHeaderLayout() -> NSCollectionLayoutSection {
        
        //reprsent cell
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(20)))
        //determine how items in a collection view are arranged
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),  heightDimension:  .absolute(20))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0)
        return section
    }
    
    public static func textViewLayout() -> NSCollectionLayoutSection {
        
        //reprsent cell
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(34)))
        //determine how items in a collection view are arranged
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),  heightDimension:  .estimated(34))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: -20, leading: 0, bottom: 0, trailing: 0)
        return section
    }
    
    public static func fileTypeLayout(itemCount: Int, isHighlight: Bool = false, indexPath: IndexPath, fileIndexPath: IndexPath) -> NSCollectionLayoutSection {
        
        //reprsent cell
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(56)))
        //determine how items in a collection view are arranged
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),  heightDimension: .estimated(CGFloat(56 * itemCount)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: itemCount)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 65, bottom: 0, trailing: 20)
        group.interItemSpacing = .fixed(10)
        let section = NSCollectionLayoutSection(group: group)
        // Create a sectionBackground
        let sectionBackground = NSCollectionLayoutDecorationItem.background(
            elementKind: "background-element-kind")
        if isHighlight && (indexPath == fileIndexPath) {
            section.decorationItems = [sectionBackground]
        } else {
            section.decorationItems = []
        }
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0)
        return section
    }
    
    public static func imageTypeLayout(itemCount: Int, isHighlight: Bool = false, indexPath: IndexPath, imageIndexPath: IndexPath) -> NSCollectionLayoutSection {
        
        //reprsent cell
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(64)))
        //determine how items in a collection view are arranged
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),  heightDimension: .estimated(64))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 5)
        group.interItemSpacing = .fixed(10)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 64, bottom: 0, trailing: 20)
        let section = NSCollectionLayoutSection(group: group)
        // Create a sectionBackground
        let sectionBackground = NSCollectionLayoutDecorationItem.background(
            elementKind: "background-element-kind")
        if isHighlight && (indexPath == imageIndexPath) {
            section.decorationItems = [sectionBackground]
        } else {
            section.decorationItems = []
        }
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0)
        return section
    }
    
    public static func userLayout() -> NSCollectionLayoutSection {
        
        //reprsent cell
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(54)))
        //determine how items in a collection view are arranged
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),  heightDimension:  .estimated(54))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        return section
    }
    
    
    public static func NoCmtLayout() -> NSCollectionLayoutSection {
        
        //reprsent cell
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(350)))
        //determine how items in a collection view are arranged
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),  heightDimension:  .estimated(350))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20)
        return section
    }
}
