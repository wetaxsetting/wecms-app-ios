//
//  PlaceholderTextView.swift
//  WABOOKS_iOS_V2
//
//  Created by Mok Monita on 11/1/21.
//

import UIKit

class PlaceholderTextView: UITextView {

    @IBInspectable var placeholderColor: UIColor = UIColor.lightGray
    @IBInspectable var placeholderText: String = "description_optional".localized

    override var font: UIFont? {
        didSet {
            setNeedsDisplay()
        }
    }

    override var contentInset: UIEdgeInsets {
        didSet {
            setNeedsDisplay()
        }
    }

    override var textAlignment: NSTextAlignment {
        didSet {
            setNeedsDisplay()
        }
    }

    override var text: String? {
        didSet {
            setNeedsDisplay()
        }
    }

    override var attributedText: NSAttributedString? {
        didSet {
            setNeedsDisplay()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }

    private func setUp() {
        NotificationCenter.default.addObserver(self,
         selector: #selector(self.textChanged(notification:)),
         name: UITextView.textDidChangeNotification,
         object: nil)
        addDoneButton()
    }

    @objc func textChanged(notification: NSNotification) {
        setNeedsDisplay()
    }

    func placeholderRectForBounds(bounds: CGRect) -> CGRect {
        var x = contentInset.left + 4.0
        var y = contentInset.top  + 9.0
        let w = frame.size.width - contentInset.left - contentInset.right - 16.0
        let h = frame.size.height - contentInset.top - contentInset.bottom - 16.0

        if let style = self.typingAttributes[NSAttributedString.Key.paragraphStyle] as? NSParagraphStyle {
            x += style.headIndent
            y += style.firstLineHeadIndent
        }
        return CGRect(x: x, y: y, width: w, height: h)
    }

    override func draw(_ rect: CGRect) {
        // Explicitly fill background — the custom draw context defaults to black
        // if not filled, since backgroundColor is on the CALayer, not the draw context.
        (backgroundColor ?? .systemBackground).setFill()
        UIRectFill(rect)

        if text!.isEmpty && !placeholderText.isEmpty {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = textAlignment
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font as Any,
                .foregroundColor: placeholderColor,
                .paragraphStyle: paragraphStyle
            ]
            placeholderText.draw(in: placeholderRectForBounds(bounds: bounds), withAttributes: attributes)
        }
        super.draw(rect)
    }
}
