// Created by Bryan Keller on 1/30/20.
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

import UIKit

/// The container view for every visual item that can be displayed in the calendar.
final class CalendarItemView: UIView {

  // MARK: Lifecycle

  init(initialCalendarItem: AnyCalendarItem) {
    calendarItem = initialCalendarItem
    contentView = calendarItem.buildView()

    super.init(frame: .zero)

    contentView.insetsLayoutMarginsFromSafeArea = false
    addSubview(contentView)

    updateViewModel()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  let contentView: UIView

  var selectionHandler: (() -> Void)?

  var calendarItem: AnyCalendarItem {
    didSet {
      guard calendarItem.reuseIdentifier == oldValue.reuseIdentifier else {
        preconditionFailure("""
          Cannot configure a reused `CalendarItemView` with a `visibleItem` that has a different
          reuse identifier (\(calendarItem.reuseIdentifier) than \(oldValue.reuseIdentifier)).
        """)
      }

      guard !calendarItem.isViewModel(equalToViewModelOf: oldValue) else { return }

      updateViewModel()
    }
  }

  override class var layerClass: AnyClass {
    CATransformLayer.self
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    contentView.frame = bounds
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)

    isHighlighted = true
  }
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches, with: event)

    isHighlighted = touches.first.map(isTouchInView(_:)) ?? false
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)

    isHighlighted = false

    if touches.first.map(isTouchInView(_:)) ?? false {
      selectionHandler?()
    }
  }

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)

    isHighlighted = false
  }

  // MARK: Private

  private var isHighlighted = false {
    didSet {
      guard isHighlighted != oldValue else { return }
      calendarItem.updateHighlightState(view: contentView, isHighlighted: isHighlighted)
    }
  }

  private func updateViewModel() {
    calendarItem.updateViewModel(view: contentView)
  }

  private func isTouchInView(_ touch: UITouch) -> Bool {
    contentView.bounds.contains(touch.location(in: contentView))
  }

}

// MARK: UIAccessibility

extension CalendarItemView {

  override var isAccessibilityElement: Bool {
    get { false }
    set { }
  }

}
