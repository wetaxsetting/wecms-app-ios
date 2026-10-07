//
//  ListPaymentCell.swift
//  WeCMS_iOS
//
//  Created by SteveChea  on 9/1/25.
//

import UIKit

class ListPaymentCell: UICollectionViewCell {
    static let identifier = "ListPaymentCell"
    
    private let title: UILabel = {
        let title = UILabel()
        title.textColor = .black
        title.textAlignment = .left
        title.translatesAutoresizingMaskIntoConstraints = false
        title.numberOfLines = 1
        title.font = UIFont(name: "Inter-Medium", size: 15.0)
        return title
    }()
    
    private let leftIcon: UIImageView = {
        let leftIcon = UIImageView()
        leftIcon.image = UIImage(named: "def_radio_off")
        leftIcon.contentMode = .scaleAspectFit
        leftIcon.translatesAutoresizingMaskIntoConstraints = false
        return leftIcon
    }()
    
    private let separatorView: UIView = {
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(hexString: "#ECEFF1")
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        return separatorView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubviews(title, leftIcon, separatorView)
        
        NSLayoutConstraint.activate([
            leftIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            leftIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            leftIcon.widthAnchor.constraint(equalToConstant: 24),
            leftIcon.heightAnchor.constraint(equalToConstant: 24),
            
            title.leadingAnchor.constraint(equalTo: leftIcon.trailingAnchor, constant: 15),
            title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            separatorView.leadingAnchor.constraint(equalTo: leftIcon.trailingAnchor, constant: 15),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configCell(listData: Expense?, indexPath : Int) {
        title.text = listData?.title ?? ""
        leftIcon.image = UIImage(named: (listData?.isSelect ?? false) ? "def_radio_on" : "def_radio_off")
    }
}
