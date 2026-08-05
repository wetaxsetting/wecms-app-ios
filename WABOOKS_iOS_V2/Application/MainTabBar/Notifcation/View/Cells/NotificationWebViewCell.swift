//
//  NotificationWebViewCell.swift
//  WABOOKS_iOS_V2
//
//  Created by Thea Chum on 3/9/21.
//

import UIKit

class NotificationWebViewCell: UICollectionViewCell {

    var baseWebview: BaseWebView?
    var urlStr                  = ""
    
    override func awakeFromNib() {
        setupWebView()
    }
    
    //MARK: - Private func
    private func checkyNotify() {
        MyNotify.listen(name: .reloadReceiptListWebView) {
            self.setupWebView()
        }
    }
    
    func setupWebView() {
        print(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        
        let navBar  = CGFloat(45.0)
        let height  = UIScreen.main.bounds.height - Shared.safeAreaBottom - Shared.safeAreaTop - navBar
        let frame   = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: UIScreen.main.bounds.width, height: height)
        
        
        self.baseWebview    = BaseWebView(withFrame: frame, andURL: urlStr)
        self.contentView.addSubview(baseWebview!)
        self.contentView.layoutIfNeeded()
    }
    
    func loadWebView(urlStr: String) {
        self.baseWebview?.urlString = urlStr
        self.baseWebview?.loadURL()
    }
}
