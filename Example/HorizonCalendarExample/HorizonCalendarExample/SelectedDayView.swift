// Created by Bryan Keller on 6/15/20.
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

// MARK: - TooltipView

final class SelectedDayView: UIView {
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

        isUserInteractionEnabled = false
        addSubview(backgroundView)
        addSubview(dateLabel)
        addSubview(notes)
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
        let labelSize = CGSize(
            width: max(dateLabel.bounds.size.width, bounds.width),
            height: dateLabel.bounds.size.height
        )

        let backgroundSize = CGSize(width: labelSize.width, height: labelSize.height)

        let proposedFrame = CGRect(
            x: frameOfTooltippedItem.minX,
            y: frameOfTooltippedItem.minY - backgroundSize.height,
            width: frameOfTooltippedItem.width,
            height: frameOfTooltippedItem.height
        )

        let frame: CGRect = if proposedFrame.maxX > bounds.width {
            proposedFrame.applying(.init(translationX: bounds.width - proposedFrame.maxX, y: 0))
        } else if proposedFrame.minX < 0 {
            proposedFrame.applying(.init(translationX: -proposedFrame.minX, y: 0))
        } else {
            proposedFrame
        }

        backgroundView.frame = frame
        dateLabel.center = backgroundView.center
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
        let frameOfTooltippedItem: CGRect?
        let text: String
        let notes: String?
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
    }
}
