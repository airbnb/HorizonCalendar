// Created by Bryan Keller on 6/15/20.
// Edited by Kyle Parker on 03/02/25
// Copyright © 2020 Airbnb Inc. All rights reserved.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import HorizonCalendar
import SwiftUICore
import UIKit

// MARK: - SelectedDayView

final class SelectedDayView: UIView, UITextFieldDelegate {
    // MARK: Lifecycle

    fileprivate init(invariantViewProperties: InvariantViewProperties) {
        backgroundView = UIView()
        backgroundView.backgroundColor = invariantViewProperties.backgroundColor
        backgroundView.layer.borderColor = invariantViewProperties.borderColor.cgColor
        backgroundView.layer.borderWidth = 1
        backgroundView.layer.cornerRadius = 6

        dateLabel = UILabel()
        dateLabel.font = invariantViewProperties.font
        dateLabel.textAlignment = invariantViewProperties.textAlignment
        dateLabel.lineBreakMode = .byTruncatingTail
        dateLabel.textColor = invariantViewProperties.textColor
        
        notes = UITextField()
        notes.font = invariantViewProperties.font
        notes.textColor = invariantViewProperties.textColor
        notes.textAlignment = invariantViewProperties.textAlignment
        notes.borderStyle = .roundedRect
        notes.placeholder = "Enter your notes here..."
        notes.layer.borderColor = invariantViewProperties.borderColor.cgColor
        notes.layer.borderWidth = 1
        notes.layer.cornerRadius = 6
        notes.backgroundColor = invariantViewProperties.backgroundColor

        super.init(frame: .zero)

        notes.delegate = self
        addSubview(backgroundView)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let frameOfTooltippedItem else { return }

        dateLabel.sizeToFit()

        let backgroundSize = CGSize(width: frameOfTooltippedItem.width,
                                    height: frameOfTooltippedItem.height)
        
        let dateLabelHeight: CGFloat = 20
        
        let buffer: CGFloat = 5

        let proposedFrame = CGRect(
            x: frameOfTooltippedItem.minX,
            y: frameOfTooltippedItem.minY - backgroundSize.height * 1.1,
            width: backgroundSize.width - 60,
            height: backgroundSize.height
        )

        backgroundView.frame = proposedFrame
        
        dateLabel.frame = CGRect(x: buffer,
                                 y: buffer,
                                 width: backgroundView.frame.width - 10,
                                 height: dateLabelHeight
        )
        
        notes.frame = CGRect(x: 5,
                             y: buffer * 2 + dateLabelHeight,
                             width: dateLabel.frame.width,
                             height: backgroundView.frame.height - dateLabelHeight - buffer * 3
        )
        notes.backgroundColor = .red
        
        dateLabel.backgroundColor = .cyan
        
        backgroundView.backgroundColor = .yellow
        
        print("notes isUserInteractionEnabled: ", notes.isUserInteractionEnabled)
        print("bgView isUserInteractionEnabled: ", backgroundView.isUserInteractionEnabled)
        print("super isUserInteractionEnabled: ", super.isUserInteractionEnabled)
        
        backgroundView.addSubview(dateLabel)
        backgroundView.addSubview(notes)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollToSelectedDate?()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Fileprivate

    fileprivate var frameOfTooltippedItem: CGRect? {
        didSet {
            guard frameOfTooltippedItem != oldValue else { return }
            setNeedsLayout()
        }
    }

    fileprivate var dateText: String {
        get { dateLabel.text ?? "" }
        set { dateLabel.text = newValue }
    }
    
    fileprivate var fieldTextContent: String {
        get { notes.text ?? "" }
        set { notes.text = newValue }
    }

    // MARK: Private

    private let backgroundView: UIView
    private let dateLabel: UILabel
    private let notes: UITextField
    private var scrollToSelectedDate: (() -> Void)?
}

// MARK: CalendarItemViewRepresentable

extension SelectedDayView: CalendarItemViewRepresentable {
    struct InvariantViewProperties: Hashable {
        var backgroundColor = UIColor.white
        var borderColor = UIColor.black
        var font = UIFont.systemFont(ofSize: 16)
        var textAlignment = NSTextAlignment.center
        var textColor = UIColor.black
    }

    struct Content: Equatable {
        static func == (lhs: SelectedDayView.Content, rhs: SelectedDayView.Content) -> Bool {
            return lhs.frameOfTooltippedItem == rhs.frameOfTooltippedItem &&
                   lhs.text == rhs.text &&
                   lhs.notes == rhs.notes
        }
        
        let frameOfTooltippedItem: CGRect?
        let text: String
        let notes: String?
        let scrollToSelectedDate: (() -> Void)?
    }

    static func makeView(
        withInvariantViewProperties invariantViewProperties: InvariantViewProperties)
        -> SelectedDayView
    {
        SelectedDayView(invariantViewProperties: invariantViewProperties)
    }

    static func setContent(_ content: Content, on view: SelectedDayView) {
        view.frameOfTooltippedItem = content.frameOfTooltippedItem
        view.dateText = content.text
        view.fieldTextContent = content.notes ?? ""
        view.scrollToSelectedDate = content.scrollToSelectedDate
    }
}
