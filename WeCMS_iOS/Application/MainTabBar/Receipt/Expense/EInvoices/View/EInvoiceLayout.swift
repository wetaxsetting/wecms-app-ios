//
//  ElectronicLayout.swift
//  WeCMS_iOS
//
//  Created by kimlang on 3/31/23.
//

import Foundation
public class EInvoiceLayout
{

    public static func listLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(10)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 0.0, leading: 0, bottom: 0, trailing: 0)
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(UIScreen.main.bounds.width),  heightDimension: .estimated(0))
       
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0.0, leading: 0, bottom: 20, trailing: 0)
   
        return section
    }
   
}

