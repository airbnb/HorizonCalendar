// Created by Bryan Keller on 11/5/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

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

// MARK: CalendarView + Double Layout Pass Helpers

/// `CalendarView`'s `intrinsicContentSize.height` should be equal to the maximum vertical space that a month can
/// occupy. This month height calculation is dependent on the available width. For a horizontally-scrolling calendar, the available width for
/// a month is dependent on the `bounds.width`, the `interMonthSpacing`, and the `maximumFullyVisibleMonths`. For
/// a vertically-scrolling calendar, the available width for a month is dependent on the `bounds.width` and any horizontal layout
/// margins.
///
/// UIKit does not provide custom views with a final width before calling `intrinsicContentSize`, making it difficult to do
/// width-dependent height calculations in time for the Auto Layout engine's layout computations. When embedding such a view in a
/// `UICollectionViewCell`  or `UITableViewCell`, self-sizing will not work correctly due to the view not having enough
/// information to return an accurate `intrinsicContentSize`. None of this is terribly surprising, since the documentation for
/// `intrinsicContentSize` specifically says "...intrinsic size must be independent of the content frame,
/// because there’s no way to dynamically communicate a changed width to the layout system based on a changed height, for
/// example."
///
/// There is one exception to this rule: `UILabel`. When `-[UILabel setNumberOfLines:]` is called with `0` as the number of
/// lines, the private method `-[UIView _needsDoubleUpdateConstraintPass]` will return `true`. UIKit will then invoke
/// `-[UILabel intrinsicContentSize]` multiple times with the most up-to-date `preferredMaxLayoutWidth`, enabling
/// the label to size correctly.
///
/// `CalendarView` can leverage `UILabel`'s double layout pass behavior by calling into this extension. Under the hood, a sizing
/// `UILabel` is used to get a second layout pass, giving `CalendarView` a chance to size itself knowing its final width.

extension CalendarView {

  func installDoubleLayoutPassSizingLabel() {
    doubleLayoutPassSizingLabel.removeFromSuperview()
    addSubview(doubleLayoutPassSizingLabel)
    subviews.first.map(doubleLayoutPassSizingLabel.sendSubviewToBack(_:))

    doubleLayoutPassSizingLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      doubleLayoutPassSizingLabel.leadingAnchor.constraint(
        equalTo: layoutMarginsGuide.leadingAnchor),
      doubleLayoutPassSizingLabel.trailingAnchor.constraint(
        equalTo: layoutMarginsGuide.trailingAnchor),
      doubleLayoutPassSizingLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
      doubleLayoutPassSizingLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
    ])
  }

  public override func invalidateIntrinsicContentSize() {
    doubleLayoutPassSizingLabel.invalidateIntrinsicContentSize()
  }

  public override func setContentHuggingPriority(
    _ priority: UILayoutPriority,
    for axis: NSLayoutConstraint.Axis)
  {
    doubleLayoutPassSizingLabel.setContentHuggingPriority(priority, for: axis)
  }

  public override func setContentCompressionResistancePriority(
    _ priority: UILayoutPriority,
    for axis: NSLayoutConstraint.Axis)
  {
    doubleLayoutPassSizingLabel.setContentCompressionResistancePriority(priority, for: axis)
  }

}

// MARK: - WidthDependentIntrinsicContentHeightProviding

protocol WidthDependentIntrinsicContentHeightProviding: CalendarView {

  func intrinsicContentSize(forHorizontallyInsetWidth width: CGFloat) -> CGSize

}

// MARK: - DoubleLayoutPassSizingLabel

final class DoubleLayoutPassSizingLabel: UILabel {

  // MARK: Lifecycle

  init(provider: WidthDependentIntrinsicContentHeightProviding) {
    self.provider = provider

    super.init(frame: .zero)

    numberOfLines = 0
    isUserInteractionEnabled = false
    isAccessibilityElement = false
    isHidden = true
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  override var intrinsicContentSize: CGSize {
    guard let provider = provider else {
      preconditionFailure(
        "The sizing label's `provider` should not be `nil` for the duration of the its life")
    }
    if preferredMaxLayoutWidth == 0 {
      return super.intrinsicContentSize
    } else {
      return provider.intrinsicContentSize(forHorizontallyInsetWidth: preferredMaxLayoutWidth)
    }
  }

  // MARK: Private

  private weak var provider: WidthDependentIntrinsicContentHeightProviding?

}

