//
//  LoadingView.swift
//  WABOOKS_iOS_V2
//
//  Created by Mok Monita on 5/1/21.
//

import UIKit

public class LoadingView: UIView {

    var spinner: UIActivityIndicatorView?
    private var coverView: UIView?

    override public var frame: CGRect {
        didSet {
            self.update()
        }
    }

    class var sharedInstance: LoadingView {
        struct Singleton {
            static let instance = LoadingView(frame: CGRect(x: 0, y: 0, width: 58.0, height: 58.0))
        }
        return Singleton.instance
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.alpha = 0.0
        self.backgroundColor = UIColor.clear
        setupSpinner()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSpinner()
    }

    private func setupSpinner() {
        if spinner == nil {
            spinner = UIActivityIndicatorView(style: .large)
            spinner?.color = .gray
            spinner?.hidesWhenStopped = true
            spinner?.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(spinner!)

            // Center spinner within LoadingView
            NSLayoutConstraint.activate([
                spinner!.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                spinner!.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ])
        }
    }

    public class func show() {
        guard let currentWindow = UIApplication.shared.keyWindowInConnectedScenes else { return }
        let view = LoadingView.sharedInstance
        view.backgroundColor = UIColor.clear

        let center = CGPoint(x: UIScreen.main.bounds.width / 2.0, y: UIScreen.main.bounds.height / 2.0)
        view.center = center

        if view.superview == nil {
            currentWindow.addSubview(view)
            view.start()
        }
    }

    public class func hide() {
        LoadingView.sharedInstance.stop()
    }

    private func start() {
        self.isUserInteractionEnabled = false
        spinner?.startAnimating()  // Safely unwraps
        self.alpha = 1.0
    }

    private func stop() {
        DispatchQueue.main.async {
            self.isUserInteractionEnabled = true
            if self.superview != nil {
                self.removeFromSuperview()
            }
            self.spinner?.stopAnimating()  // Safely unwraps
            self.alpha = 0.0
        }
    }

    private func update() {
        if spinner == nil {
            setupSpinner() // Ensure spinner is initialized
        }
    }
    
    private func dismiss(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            LoadingView.hide()
        }) { _ in
            completion?(true)
        }
    }
    public class func delayBeforeHide(seconds: Double = 0.3, completion: ((Bool) -> Void)? = nil) {
        let time = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            LoadingView.sharedInstance.dismiss(completion: completion)
        }
    }
}
