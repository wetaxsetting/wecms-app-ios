//
//  NavigationBar.swift
//  WABOOKS_iOS_V2
//
//  Created by Bong Kokkheang on 16/1/24.
//

import UIKit

class NavigationBar: UIView {
    
    private static let NIB_NAME = "NavigationBar"
    
    @IBOutlet weak var barView: UIView!
    @IBOutlet var view: UIView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var rightButton: UIButton!
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var subTitle: String = "" {
        didSet {
            subTitleLabel.text = subTitle
            subTitleLabel.isHidden = false
        }
    }
    
    var hideDesc: Bool = false {
        didSet {
            subTitleLabel.isHidden = hideDesc
        }
    }
    
    override func awakeFromNib() {
        initWithNib()
    }
    
    private func initWithNib() {
        Bundle.main.loadNibNamed(NavigationBar.NIB_NAME, owner: self, options: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.isHidden = true
        addSubview(view)
        setupLayout()
        //add format localized font khmer
        titleLabel.getlocalizedFont()
        subTitleLabel.getlocalizedFont()
        rightButton.getlocalizedFont()
        leftButton.getlocalizedFont()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate(
            [
                view.topAnchor.constraint(equalTo: topAnchor),
                view.leadingAnchor.constraint(equalTo: leadingAnchor),
                view.bottomAnchor.constraint(equalTo: bottomAnchor),
                view.trailingAnchor.constraint(equalTo: trailingAnchor),
            ]
        )
    }
    
    @IBAction func leftButtonPressed(_ sender: Any) {
        if let nav = parentViewController?.navigationController {
            nav.popViewController(animated: true)
        }
    }
}
