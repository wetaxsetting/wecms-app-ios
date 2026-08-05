//
//  UITextView.swift
//  WABOOKS_iOS_V2
//
//  Created by Udam Chheng on 15/8/25.
//

extension UITextField {

    open override func awakeFromNib() {
        super.awakeFromNib()
        addDoneButton()
    }

    func addDoneButton() {
        guard inputAccessoryView == nil else { return }
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(resignFirstResponder))
        toolbar.items = [flex, done]
        inputAccessoryView = toolbar
    }
}

extension UITextView {

    open override func awakeFromNib() {
        super.awakeFromNib()
        addDoneButton()
    }

    func addDoneButton() {
        guard inputAccessoryView == nil else { return }
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(resignFirstResponder))
        toolbar.items = [flex, done]
        inputAccessoryView = toolbar
    }

    /// Set HTML content with proper formatting for UITextView
    /// - Parameters:
    ///   - htmlString: HTML string to display
    ///   - fontSize: Base font size (default: 16)
    ///   - textColor: Text color (default: label)
    ///   - makeLinksClickable: Enable link detection (default: true)
    func setHTMLContent(
        _ htmlString: String,
        fontSize: CGFloat = 16,
        textColor: UIColor = .label,
        makeLinksClickable: Bool = true
    ) {
        
        if makeLinksClickable {
            self.dataDetectorTypes = [.link]
        }
        
        // Parse HTML to attributed string
        if let attributedText = htmlString.parseHTMLForTextView(
            fontSize: fontSize
        ) {
            self.attributedText = attributedText
        } else {
            // Fallback to plain text
            self.text = htmlString.stripHTMLAndFormat()
            self.font = UIFont.systemFont(ofSize: fontSize)
            self.textColor = textColor
        }
    }
    
    /// Simple HTML content setter
    /// - Parameter htmlString: HTML string to display
    func setHTMLText(_ htmlString: String) {
        setHTMLContent(htmlString)
    }
    
}
