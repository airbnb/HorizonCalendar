// Created by Bryan Keller on 9/12/21.
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

// MARK: - DayOfWeekView

/// A view that represents a day-of-the-week header in a calendar month. For example, Sun, Mon, Tue, etc.
public final class DayOfWeekView: UIView {

  // MARK: Lifecycle

  public init(invariantViewProperties: InvariantViewProperties) {
    self.invariantViewProperties = invariantViewProperties

    backgroundLayer = CAShapeLayer()
    let backgroundShapeDrawingConfig = invariantViewProperties.backgroundShapeDrawingConfig
    backgroundLayer.fillColor = backgroundShapeDrawingConfig.fillColor.cgColor
    backgroundLayer.strokeColor = backgroundShapeDrawingConfig.borderColor.cgColor
    backgroundLayer.lineWidth = backgroundShapeDrawingConfig.borderWidth

    label = UILabel()
    label.font = invariantViewProperties.font
    label.textAlignment = invariantViewProperties.textAlignment
    label.textColor = invariantViewProperties.textColor

    super.init(frame: .zero)

    isUserInteractionEnabled = false

    backgroundColor = invariantViewProperties.backgroundColor

    layer.addSublayer(backgroundLayer)

    addSubview(label)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public override func layoutSubviews() {
    super.layoutSubviews()

    let edgeInsets = invariantViewProperties.edgeInsets
    let insetBounds = bounds.inset(
      by: UIEdgeInsets(
        top: edgeInsets.top,
        left: edgeInsets.leading,
        bottom: edgeInsets.bottom,
        right: edgeInsets.trailing))

    let path: CGPath
    switch invariantViewProperties.shape {
    case .circle:
      path = UIBezierPath(
        ovalIn: CGRect(
          origin: CGPoint(x: edgeInsets.leading, y: edgeInsets.top),
          size: insetBounds.size)).cgPath

    case .rectangle(let cornerRadius):
      path = UIBezierPath(roundedRect: insetBounds, cornerRadius: cornerRadius).cgPath
    }

    backgroundLayer.path = path

    label.frame = CGRect(
      x: edgeInsets.leading,
      y: edgeInsets.top,
      width: insetBounds.width,
      height: insetBounds.height)
  }

  // MARK: Fileprivate

  fileprivate func setViewModel(_ viewModel: ViewModel) {
    label.text = viewModel.dayOfWeekText
    accessibilityLabel = viewModel.accessibilityLabel
  }

  // MARK: Private

  private let invariantViewProperties: InvariantViewProperties
  private let backgroundLayer: CAShapeLayer
  private let label: UILabel

}

// MARK: Accessibility

extension DayOfWeekView {

  public override var isAccessibilityElement: Bool {
    get { true }
    set { }
  }

  public override var accessibilityTraits: UIAccessibilityTraits {
    get { invariantViewProperties.accessibilityTraits }
    set { }
  }

}

// MARK: - DayView.ViewModel

extension DayOfWeekView {

  /// Encapsulates the data used to populate a `DayOfWeekView`'s text label. Use the `Calendar` with which you initialized
  /// your `CalendarView` to access localized weekday symbols. For example, you can use
  /// `calendar.shortWeekdaySymbols` or `calendar.veryShortWeekdaySymbols`. For the `accessibilityLabel`,
  /// consider using the full-length symbol names in `calendar.weekdaySymbols`.
  public struct ViewModel: Equatable {

    // MARK: Lifecycle

    public init(dayOfWeekText: String, accessibilityLabel: String?) {
      self.dayOfWeekText = dayOfWeekText
      self.accessibilityLabel = accessibilityLabel
    }

    // MARK: Public

    public let dayOfWeekText: String
    public let accessibilityLabel: String?
  }

}

// MARK: - DayOfWeekView.InvariantViewProperties

extension DayOfWeekView {

  /// Encapsulates configurable properties that change the appearance and behavior of `DayOfWeekView`. These cannot be
  /// changed after a `DayOfWeekView` is initialized.
  public struct InvariantViewProperties: Hashable {

    // MARK: Lifecycle

    private init() { }

    // MARK: Public

    public static let base = InvariantViewProperties()

    /// The background color of the entire view, unaffected by `edgeInsets` and behind the background layer.
    public var backgroundColor = UIColor.clear

    /// Edge insets that apply to the background layer and text label.
    public var edgeInsets = NSDirectionalEdgeInsets.zero

    /// The shape of the the background layer.
    public var shape = Shape.circle

    /// The drawing config for the always-visible background layer.
    public var backgroundShapeDrawingConfig = DrawingConfig()

    /// The font of the day-of-the-week label.
    public var font = UIFont.systemFont(ofSize: 16)

    /// The text alignment of the day-of-the-week label.
    public var textAlignment = NSTextAlignment.center

    /// The text color of the day-of-the-week label.
    public var textColor: UIColor = {
      if #available(iOS 13.0, *) {
        return .secondaryLabel
      } else {
        return .black
      }
    }()

    /// Whether or not the `DayOfWeekView` is an accessibility element or not.
    ///
    /// By default, this property is set to `false`. It may not be necessary for individual day-of-the-week headers to be focused by
    /// VoiceOver, especially when your day views have accessibility labels that include the day of the week. For example, your day
    /// view might have an accessibility label of "Sunday, September 12th, 2021."
    public var isAccessibilityElement = false

    /// The accessibility traits of the `DayOfWeekView`.
    public var accessibilityTraits = UIAccessibilityTraits.none

  }

}

// MARK: - DayOfWeekView + CalendarItemViewRepresentable

extension DayOfWeekView: CalendarItemViewRepresentable {

  public static func makeView(
    withInvariantViewProperties invariantViewProperties: InvariantViewProperties)
    -> DayOfWeekView
  {
    DayOfWeekView(invariantViewProperties: invariantViewProperties)
  }

  public static func setViewModel(_ viewModel: ViewModel, on view: DayOfWeekView) {
    view.setViewModel(viewModel)
  }

}
