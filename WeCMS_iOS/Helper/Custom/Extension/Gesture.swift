//
//  Gesture.swift
//  WeCMS_iOS
//
//  Created by Mok Monita on 5/1/21.
//

import Foundation
import UIKit

extension UIView {
   
   func didTap(completion: @escaping Completion) {
       let tap = CompletionGesture(target: self, action: #selector(didTapCallback(_:)))
       tap.completion = completion
       
       self.isUserInteractionEnabled = true
       addGestureRecognizer(tap)
   }
   
   @objc fileprivate func didTapCallback(_ sender: CompletionGesture) {
       sender.completion()
   }
   
   // ----------------------------------------------------------------------
   func addTapGesture(target: Any?, selector: Selector) {
       self.isUserInteractionEnabled = true
       self.addGestureRecognizer(
           UITapGestureRecognizer(target: target, action: selector)
       )
   }
   
   func addPanGesture(target: Any?, selector: Selector) {
       self.isUserInteractionEnabled = true
       self.addGestureRecognizer(
           UIPanGestureRecognizer(target: target, action: selector)
       )
   }
}

class CompletionGesture: UITapGestureRecognizer {
   var completion = { }
}

class MyTapGesture: UITapGestureRecognizer {
   var dic = [String: AnyObject]()
}

// ------------------------------------------------------------------

/// Target-Action helper.
class Action: NSObject {
   private var _action = { }
   
   init(action: @escaping () -> Void) {
       super.init()
       self._action = action
   }
   
   @objc func action() {
       _action()
   }
}

 
