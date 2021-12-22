// Created by Bryan Keller on 9/11/21.
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

// MARK: - DayView

/// A view that represents a day in the calendar.
public final class DayView: UIView {

  // MARK: Lifecycle

  public init(invariantViewProperties: InvariantViewProperties) {
    self.invariantViewProperties = invariantViewProperties

    backgroundLayer = CAShapeLayer()
    let backgroundShapeDrawingConfig = invariantViewProperties.backgroundShapeDrawingConfig
    backgroundLayer.fillColor = backgroundShapeDrawingConfig.fillColor.cgColor
    backgroundLayer.strokeColor = backgroundShapeDrawingConfig.borderColor.cgColor
    backgroundLayer.lineWidth = backgroundShapeDrawingConfig.borderWidth

    let isUserInteractionEnabled: Bool
    let supportsPointerInteraction: Bool
    switch invariantViewProperties.interaction {
    case .disabled:
      isUserInteractionEnabled = false
      supportsPointerInteraction = false
      highlightLayer = nil

    case let .enabled(_, _supportsPointerInteraction):
      isUserInteractionEnabled = true
      supportsPointerInteraction = _supportsPointerInteraction

      highlightLayer = CAShapeLayer()
      let highlightShapeDrawingConfig = invariantViewProperties.highlightShapeDrawingConfig
      highlightLayer?.fillColor = highlightShapeDrawingConfig.fillColor.cgColor
      highlightLayer?.strokeColor = highlightShapeDrawingConfig.borderColor.cgColor
      highlightLayer?.lineWidth = highlightShapeDrawingConfig.borderWidth
    }

    label = UILabel()
    label.font = invariantViewProperties.font
    label.textAlignment = invariantViewProperties.textAlignment
    label.textColor = invariantViewProperties.textColor

    super.init(frame: .zero)

    self.isUserInteractionEnabled = isUserInteractionEnabled

    backgroundColor = invariantViewProperties.backgroundColor

    layer.addSublayer(backgroundLayer)
    highlightLayer.map { layer.addSublayer($0) }

    addSubview(label)

    setHighlightLayerVisibility(isHidden: true, animated: false)

    if #available(iOS 13.4, *), supportsPointerInteraction {
      addInteraction(UIPointerInteraction(delegate: self))
    }
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
      let radius = min(insetBounds.size.width, insetBounds.size.height) / 2
      let origin = CGPoint(x: insetBounds.midX - radius, y: insetBounds.midY - radius)
      let size = CGSize(width: radius * 2, height: radius * 2)
      path = UIBezierPath(ovalIn: CGRect(origin: origin, size: size)).cgPath

    case .rectangle(let cornerRadius):
      path = UIBezierPath(roundedRect: insetBounds, cornerRadius: cornerRadius).cgPath
    }

    backgroundLayer.path = path
    highlightLayer?.path = path

    label.frame = CGRect(
      x: edgeInsets.leading,
      y: edgeInsets.top,
      width: insetBounds.width,
      height: insetBounds.height)
  }

  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)

    setHighlightLayerVisibility(isHidden: false, animated: true)

    if
      case let .enabled(playsHapticsOnTouchDown, _) = invariantViewProperties.interaction,
      playsHapticsOnTouchDown
    {
      feedbackGenerator = UISelectionFeedbackGenerator()
      feedbackGenerator?.prepare()
    }
  }

  public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)

    setHighlightLayerVisibility(isHidden: true, animated: true)

    feedbackGenerator?.selectionChanged()
    feedbackGenerator = nil
  }

  public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)

    setHighlightLayerVisibility(isHidden: true, animated: true)
    feedbackGenerator = nil
  }

  // MARK: Fileprivate

  fileprivate func setViewModel(_ viewModel: ViewModel) {
    label.text = viewModel.dayText

    accessibilityLabel = viewModel.accessibilityLabel
    accessibilityHint = viewModel.accessibilityHint
  }

  // MARK: Private

  private let invariantViewProperties: InvariantViewProperties
  private let backgroundLayer: CAShapeLayer
  private let highlightLayer: CAShapeLayer?
  private let label: UILabel

  private var feedbackGenerator: UISelectionFeedbackGenerator?

  private func setHighlightLayerVisibility(isHidden: Bool, animated: Bool) {
    guard let highlightLayer = highlightLayer else { return }

    let opacity: Float = isHidden ? 0 : 1

    if animated {
      let animation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
      animation.fromValue = highlightLayer.presentation()?.opacity ?? highlightLayer.opacity
      animation.toValue = opacity
      animation.duration = 0.1
      animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
      highlightLayer.add(animation, forKey: "fade")
    }

    highlightLayer.opacity = opacity
  }

}

// MARK: Accessibility

extension DayView {

  public override var isAccessibilityElement: Bool {
    get { true }
    set { }
  }

  public override var accessibilityTraits: UIAccessibilityTraits {
    get { invariantViewProperties.accessibilityTraits }
    set { }
  }

}

// MARK: UIPointerInteractionDelegate

@available(iOS 13.4, *)
extension DayView: UIPointerInteractionDelegate {

  public func pointerInteraction(
    _ interaction: UIPointerInteraction,
    styleFor region: UIPointerRegion)
    -> UIPointerStyle?
  {
    guard let interactionView = interaction.view else { return nil }

    let previewParameters = UIPreviewParameters()
    previewParameters.visiblePath = backgroundLayer.path.map { UIBezierPath(cgPath: $0) }

    let targetedPreview = UITargetedPreview(view: interactionView, parameters: previewParameters)

    return UIPointerStyle(effect: .highlight(targetedPreview))
  }

}

// MARK: - DayView.ViewModel

extension DayView {

  /// Encapsulates the data used to populate a `DayView`'s text label. Use a `DateFormatter` to create the
  /// `accessibilityLabel` string.
  ///
  /// - Note: To avoid performance issues, reuse the same `DateFormatter` for each day, rather than creating
  /// a new `DateFormatter` for each day.
  public struct ViewModel: Equatable {

    // MARK: Lifecycle

    public init(
      dayText: String,
      accessibilityLabel: String?,
      accessibilityHint: String?)
    {
      self.dayText = dayText
      self.accessibilityLabel = accessibilityLabel
      self.accessibilityHint = accessibilityHint
    }

    // MARK: Public

    public let dayText: String
    public let accessibilityLabel: String?
    public let accessibilityHint: String?
  }

}

// MARK: - DayView.InvariantViewProperties

extension DayView {

  /// Encapsulates configurable properties that change the appearance and behavior of `DayView`. These cannot be changed after a
  /// `DayView` is initialized.
  public struct InvariantViewProperties: Hashable {

    // MARK: Lifecycle

    private init() { }

    // MARK: Public

    public enum Interaction: Hashable {
      case disabled
      case enabled(playsHapticsOnTouchDown: Bool = true, supportsPointerInteraction: Bool = true)
    }

    public static let baseNonInteractive = InvariantViewProperties()
    public static let baseInteractive: InvariantViewProperties = {
      var properties = baseNonInteractive
      properties.interaction = .enabled()
      properties.accessibilityTraits = .button
      return properties
    }()

    /// Whether user interaction is enabled or disabled. If this is set to disabled, the highlight layer will not appear on touch down and
    /// and `isUserInteractionEnabled` will be set to `false`.
    public var interaction = Interaction.disabled

    /// The background color of the entire view, unaffected by `edgeInsets` and behind the background and highlight layers.
    public var backgroundColor = UIColor.clear

    /// Edge insets that apply to the background layer, highlight layer, and text label.
    public var edgeInsets = NSDirectionalEdgeInsets.zero

    /// The shape of the the background and highlight layers.
    public var shape = Shape.circle

    /// The drawing config for the always-visible background layer.
    public var backgroundShapeDrawingConfig = DrawingConfig.transparent

    /// The drawing config for the highlight layer that shows up on touch-down if `self.interaction` is `.enabled`.
    public var highlightShapeDrawingConfig: DrawingConfig = {
      let color: UIColor
      if #available(iOS 13.0, *) {
        color = .systemFill
      } else {
        color = .lightGray
      }

      return DrawingConfig(fillColor: color, borderColor: color)
    }()

    /// The font of the day's label.
    public var font = UIFont.systemFont(ofSize: 18)

    /// The text alignment of the day's label.
    public var textAlignment = NSTextAlignment.center

    /// The text color of the day's label.
    public var textColor: UIColor = {
      if #available(iOS 13.0, *) {
        return .label
      } else {
        return .black
      }
    }()

    /// The accessibility traits of the `DayView`.
    public var accessibilityTraits = UIAccessibilityTraits.staticText

  }

}

// MARK: - DayView + CalendarItemViewRepresentable

extension DayView: CalendarItemViewRepresentable {

  public static func makeView(
    withInvariantViewProperties invariantViewProperties: InvariantViewProperties)
    -> DayView
  {
    DayView(invariantViewProperties: invariantViewProperties)
  }

  public static func setViewModel(_ viewModel: ViewModel, on view: DayView) {
    view.setViewModel(viewModel)
  }

}
