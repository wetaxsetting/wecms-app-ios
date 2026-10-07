//
//  ArticleLayout.swift
//  WeCMS_iOS
//
//  Created by Bong Kokkheang on 11/1/24.
//

import Foundation
import UIKit

public class CommentViewLayout {
    
    public static func textViewLayout() -> NSCollectionLayoutSection {
        
        //reprsent cell
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(34)))
        //determine how items in a collection view are arranged
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),  heightDimension:  .estimated(34))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        return section
    }
    
    public static func fileTypeLayout(countItem: Int) -> NSCollectionLayoutSection {
        
        //reprsent cell
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(56)))
        item.contentInsets.top = 10
        //determine how items in a collection view are arranged
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),  heightDimension: .estimated(CGFloat(66 * countItem)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: countItem)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        return section
    }
    
    public static func imageTypeLayout(countItem: Int) -> NSCollectionLayoutSection {
        
        //reprsent cell
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(64), heightDimension: .absolute(100)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0)
        //determine how items in a collection view are arranged
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),  heightDimension: .estimated(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(10)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        return section
    }
}
