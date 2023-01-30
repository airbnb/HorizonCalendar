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
final class ItemView: UIView {

  // MARK: Lifecycle

  init(initialCalendarItemModel: InternalAnyCalendarItemModel) {
    calendarItemModel = initialCalendarItemModel
    contentView = calendarItemModel.makeView()

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

  var calendarItemModel: InternalAnyCalendarItemModel {
    didSet {
      guard calendarItemModel.itemViewDifferentiator == oldValue.itemViewDifferentiator else {
        preconditionFailure("""
          Cannot configure a reused `ItemView` with a calendar item model that was created with a
          different instance of invariant view properties.
        """)
      }

      // Only update the view model if it's different from the old one.
      guard !calendarItemModel.isViewModelEqualToViewModelOfOther(oldValue) else { return }

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

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)

    if touches.first.map(isTouchInView(_:)) ?? false {
      selectionHandler?()
    }
  }

  // MARK: Private

  private func updateViewModel() {
    calendarItemModel.setViewModelOnViewOfSameType(contentView)
  }

  private func isTouchInView(_ touch: UITouch) -> Bool {
    contentView.bounds.contains(touch.location(in: contentView))
  }

}

// MARK: UIAccessibility

extension ItemView {

  override var isAccessibilityElement: Bool {
    get { false }
    set { }
  }

}
