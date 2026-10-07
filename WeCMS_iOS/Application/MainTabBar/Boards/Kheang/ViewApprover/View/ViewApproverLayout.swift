//
//  ViewApproverLayout.swift
//  WeCMS_iOS
//
//  Created by Kimlang on 31/1/24.
//


import Foundation
import UIKit

public class ViewApproverLayout {
    
    static func listLayout(data: ApproverData) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(data.date != nil ? 65 : 42)))
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(UIScreen.main.bounds.width),  heightDimension: .estimated(data.date != nil ? 65 : 42))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0)
        return section
    }
    
    public static func requestorLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(42)))
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(UIScreen.main.bounds.width),  heightDimension: .estimated(42))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
        return section
    }
    
}
