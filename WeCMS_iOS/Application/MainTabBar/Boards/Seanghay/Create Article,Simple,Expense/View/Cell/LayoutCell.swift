//
//  LayoutCell.swift
//  WeCMS_iOS
//
//  Created by SteveChea  on 24/1/24.
//

import UIKit


class DateFilterLayout{
    
    func LastOneMonthLayout(topSpace: CGFloat? = nil, bottomSpace: CGFloat? = nil) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(48)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 0.0, leading: 0, bottom: 0.0, trailing: 0)
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(UIScreen.main.bounds.width),  heightDimension: .estimated(48))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: topSpace ?? 0.0, leading: 0.0, bottom: bottomSpace ?? 0.0, trailing: 0.0)
        return section
    }
    
    
//
//    func quickBuyLayout(size: NSCollectionLayoutSize, itemInset:NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 10.0), sectionInset: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(top: -20.0, leading: 30.0, bottom: 0.0, trailing: 20.0)) -> NSCollectionLayoutSection {
//            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
//            item.contentInsets = itemInset
//            let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitem: item, count: 1)
//            let section = NSCollectionLayoutSection(group: group)
//            section.contentInsets = sectionInset
//            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
//            return section
//        }
}
