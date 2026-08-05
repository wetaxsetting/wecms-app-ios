//
//  VCPreviewTableViewController.swift
//  ContextMenu
//
//  Created by Kyle Bashour on 8/20/19.
//  Copyright © 2019 Kyle Bashour. All rights reserved.
//

import UIKit

protocol ContextMenuDemo {
//    static var title: String { get }
}

extension ContextMenuDemo {
    func makeDefaultDemoMenu() -> UIMenu {

        // Create a UIAction for sharing
//        let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { action in
////             Show system share sheet
//        }

        // Create and return a UIMenu with all of the actions as children
        return UIMenu(title: "", children: [])
    }
}


/*

 This view controller displays a list of icons with their names, and uses a view controller for the menu preview.
 When the preview is tapped, it pushes that view controller.

 */

/// A view controller used for previewing and when an item is selected
class PhotoPreviewViewController: UIViewController {
    private let image       : UIImage?
    private let imageView   = UIImageView()
    
    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image             = image ?? UIImage(named: "noimage")
        imageView.clipsToBounds     = true
        imageView.contentMode       = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.didTap {
            self.dismiss(animated: true) {}
        }
        
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo   : view.leftAnchor),
            imageView.rightAnchor.constraint(equalTo  : view.rightAnchor),
            imageView.topAnchor.constraint(equalTo    : view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo : view.bottomAnchor),
        ])

        // The preview will size to the preferredContentSize, which can be useful
        // for displaying a preview with the dimension of an image, for example.
        // Unlike peek and pop, it doesn't automatically scale down for you.

        let width   = view.bounds.width
        let height  = image!.size.height * (width / image!.size.width)
        preferredContentSize = CGSize(width: width, height: height)
    }
}

/// Displays the name of the image
class PhotoDetailViewController: UIViewController {
    private let imageName       : String
    private let imageNameLabel  = UILabel()

    init(imageName: String) {
        self.imageName = imageName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = imageName.capitalized
        view.backgroundColor = .secondarySystemBackground

        imageNameLabel.font             = UIFont.preferredFont(forTextStyle: .largeTitle)
        imageNameLabel.textColor        = .label
        imageNameLabel.textAlignment    = .center
        imageNameLabel.text             = imageName.capitalized
        imageNameLabel.sizeToFit()
        view.addSubview(imageNameLabel)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageNameLabel.center = view.center
    }
}
