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

// MARK: - ItemView

/// The container view for every visual item that can be displayed in the calendar.
final class ItemView: UIView {

  // MARK: Lifecycle

  init(initialCalendarItemModel: AnyCalendarItemModel) {
    calendarItemModel = initialCalendarItemModel
    contentView = calendarItemModel._makeView()

    super.init(frame: .zero)

    contentView.insetsLayoutMarginsFromSafeArea = false
    addSubview(contentView)

    updateContent()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  override class var layerClass: AnyClass {
    CATransformLayer.self
  }

  let contentView: UIView

  var selectionHandler: (() -> Void)?

  var itemType: VisibleItem.ItemType?

  override var isAccessibilityElement: Bool {
    get { false }
    set { }
  }

  override var isHidden: Bool {
    get { contentView.isHidden }
    set { contentView.isHidden = newValue }
  }

  var calendarItemModel: AnyCalendarItemModel {
    didSet {
      guard calendarItemModel._itemViewDifferentiator == oldValue._itemViewDifferentiator else {
        preconditionFailure("""
            Cannot configure a reused `ItemView` with a calendar item model that was created with a
            different instance of invariant view properties.
          """)
      }

      // Only update the content if it's different from the old one.
      guard !calendarItemModel._isContentEqual(toContentOf: oldValue) else { return }

      updateContent()
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    contentView.frame = bounds
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)

    func isTouchInView(_ touch: UITouch) -> Bool {
      contentView.bounds.contains(touch.location(in: contentView))
    }

    if touches.first.map(isTouchInView(_:)) ?? false {
      selectionHandler?()
    }
  }

  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let view = super.hitTest(point, with: event)

    // If the returned view is `self`, that means that our `contentView` isn't interactive for this
    // `point`. This can happen if the `contentView` also overrides `hitTest` or `pointInside` to
    // customize the interaction. It can also happen if our `contentView` has
    // `isUserInteractionEnabled` set to `false`.
    if view === self {
      return nil
    }

    return view
  }

  // MARK: Private

  private func updateContent() {
    calendarItemModel._setContent(onViewOfSameType: contentView)
  }

}
