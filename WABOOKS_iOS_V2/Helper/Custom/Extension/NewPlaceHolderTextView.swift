//
//  NewPlaceHolderTextView.swift
//  WABOOKS_iOS_V2
//
//  Created by Kimlang on 24/1/24.
//

import Foundation
import UIKit

class NewPlaceHolderTextView: UITextView {

    // MARK: - Properties

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        return label
    }()

    var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
        }
    }

    // MARK: - Initialization

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        // Set up placeholder label
        placeholderLabel.font = font
        placeholderLabel.isHidden = !text.isEmpty
        addSubview(placeholderLabel)

        // Set up UITextView delegate
        delegate = self

        // Add constraints for placeholder label
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            placeholderLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -8)
        ])
        addDoneButton()
    }

}
// MARK: - UITextViewDelegate

extension NewPlaceHolderTextView: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }

}
