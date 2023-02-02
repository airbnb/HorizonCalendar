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
import UIKit

// MARK: - TooltipView

final class TooltipView: UIView {

  // MARK: Lifecycle

  fileprivate init(invariantViewProperties: InvariantViewProperties) {
    backgroundView = UIView()
    backgroundView.backgroundColor = invariantViewProperties.backgroundColor
    backgroundView.layer.borderColor = invariantViewProperties.borderColor.cgColor
    backgroundView.layer.borderWidth = 1
    backgroundView.layer.cornerRadius = 6

    label = UILabel()
    label.font = invariantViewProperties.font
    label.textAlignment = invariantViewProperties.textAlignment
    label.lineBreakMode = .byTruncatingTail
    label.textColor = invariantViewProperties.textColor

    super.init(frame: .zero)

    addSubview(backgroundView)
    addSubview(label)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  override func layoutSubviews() {
    super.layoutSubviews()

    guard let frameOfTooltippedItem = frameOfTooltippedItem else { return }

    label.sizeToFit()
    let labelSize = CGSize(
      width: min(label.bounds.size.width, bounds.width),
      height: label.bounds.size.height)

    let backgroundSize = CGSize(width: labelSize.width + 16, height: labelSize.height + 16)

    let proposedFrame = CGRect(
      x: frameOfTooltippedItem.midX - (backgroundSize.width / 2),
      y: frameOfTooltippedItem.minY - backgroundSize.height - 4,
      width: backgroundSize.width,
      height: backgroundSize.height)

    let frame: CGRect
    if proposedFrame.maxX > bounds.width {
      frame = proposedFrame.applying(.init(translationX: bounds.width - proposedFrame.maxX, y: 0))
    } else if proposedFrame.minX < 0 {
      frame = proposedFrame.applying(.init(translationX: -proposedFrame.minX, y: 0))
    } else {
      frame = proposedFrame
    }

    backgroundView.frame = frame
    label.center = backgroundView.center
  }

  // MARK: Fileprivate

  fileprivate var frameOfTooltippedItem: CGRect? {
    didSet {
      guard frameOfTooltippedItem != oldValue else { return }
      setNeedsLayout()
    }
  }

  fileprivate var text: String {
    get { label.text ?? "" }
    set { label.text = newValue }
  }

  // MARK: Private

  private let backgroundView: UIView
  private let label: UILabel

}

// MARK: CalendarItemViewRepresentable

extension TooltipView: CalendarItemViewRepresentable {

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
  }

  static func makeView(
    withInvariantViewProperties invariantViewProperties: InvariantViewProperties)
    -> TooltipView
  {
    TooltipView(invariantViewProperties: invariantViewProperties)
  }

  static func setContent(_ content: Content, on view: TooltipView) {
    view.frameOfTooltippedItem = content.frameOfTooltippedItem
    view.text = content.text
  }

}
