//
//  ItemsCell.swift
//  WABOOKS_iOS_V2
//
//  Created by SteveChea  on 14/1/25.
//

import Foundation

class ItemsCell: UITableViewCell{
    
    private let leftTitleLabel: UILabel = {
        let leftTitleLabel = UILabel()
        leftTitleLabel.textColor = UIColor(hexString: "#494949")
        leftTitleLabel.textAlignment = .left
        leftTitleLabel.numberOfLines = 1
        leftTitleLabel.font = UIFont(name: "Inter-Medium", size: 13)
        leftTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        return leftTitleLabel
    }()
    
    private let rightTitleLabel: UILabel = {
        let rightTitleLabel = UILabel()
        rightTitleLabel.textColor = UIColor(hexString: "#494949")
        rightTitleLabel.textAlignment = .left
        rightTitleLabel.numberOfLines = 1
        rightTitleLabel.font = UIFont(name: "Inter-Medium", size: 13)
        rightTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        return rightTitleLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(){
        let stackView = UIStackView(arrangedSubviews: [leftTitleLabel, rightTitleLabel])
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            leftTitleLabel.widthAnchor.constraint(equalToConstant: 45)
        ])
    }
    
    func configCell(_ data: Items){
        leftTitleLabel.text = data.code
        rightTitleLabel.text = data.title
    }
}
