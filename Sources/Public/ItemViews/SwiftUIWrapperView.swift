// Created by Bryan Keller on 10/12/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

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

import SwiftUI

// MARK: - SwiftUIWrapperView

/// A wrapper view that enables SwiftUI `View`s to be used with `CalendarItemModel`s.
///
/// Consider using the `calendarItemModel` property, defined as an extension on SwiftUI's`View`, to avoid needing to work with
/// this wrapper view directly.
/// e.g. `Text("\(dayNumber)").calendarItemModel`
@available(iOS 13.0, *)
public final class SwiftUIWrapperView<Content: View>: UIView {

  // MARK: Lifecycle

  public init(contentAndID: ContentAndID) {
    self.contentAndID = contentAndID
    hostingController = UIHostingController(rootView: contentAndID.content)
    hostingController._disableSafeArea = true

    super.init(frame: .zero)

    insetsLayoutMarginsFromSafeArea = false
    layoutMargins = .zero

    hostingControllerView.backgroundColor = .clear
    addSubview(hostingControllerView)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public override class var layerClass: AnyClass {
    CATransformLayer.self
  }

  public override var isAccessibilityElement: Bool {
    get { false }
    set { }
  }

  public override var isHidden: Bool {
    didSet {
      if isHidden {
        hostingControllerView.removeFromSuperview()
      } else {
        addSubview(hostingControllerView)
      }
    }
  }

  public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    // `_UIHostingView`'s `isUserInteractionEnabled` is not affected by the `allowsHitTesting`
    // modifier. Its first subview's `isUserInteractionEnabled` _does_ appear to be affected by the
    // `allowsHitTesting` modifier, enabling us to properly ignore touch handling.
    if
      let firstSubview = hostingControllerView.subviews.first,
      !firstSubview.isUserInteractionEnabled
    {
      return false
    } else {
      return super.point(inside: point, with: event)
    }
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    hostingControllerView.frame = bounds
  }

  public override func systemLayoutSizeFitting(
    _ targetSize: CGSize,
    withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
    verticalFittingPriority: UILayoutPriority)
    -> CGSize
  {
    hostingControllerView.systemLayoutSizeFitting(
      targetSize,
      withHorizontalFittingPriority: horizontalFittingPriority,
      verticalFittingPriority: verticalFittingPriority)
  }

  // MARK: Fileprivate

  fileprivate var contentAndID: ContentAndID {
    didSet {
      hostingController.rootView = contentAndID.content
      configureGestureRecognizers()
    }
  }

  // MARK: Private

  private let hostingController: UIHostingController<Content>

  private var hostingControllerView: UIView {
    hostingController.view
  }

  // This allows touches to be passed to `ItemView` even if the SwiftUI `View` has a gesture
  // recognizer.
  private func configureGestureRecognizers() {
    for gestureRecognizer in hostingControllerView.gestureRecognizers ?? [] {
      gestureRecognizer.cancelsTouchesInView = false
    }
  }

}

// MARK: CalendarItemViewRepresentable

@available(iOS 13.0, *)
extension SwiftUIWrapperView: CalendarItemViewRepresentable {

  public struct InvariantViewProperties: Hashable {

    // MARK: Lifecycle

    init(initialContentAndID: ContentAndID) {
      self.initialContentAndID = initialContentAndID
    }

    // MARK: Public

    public static func == (_: InvariantViewProperties, _: InvariantViewProperties) -> Bool {
      // Always true since two `SwiftUIWrapperView`'s with the same `Content` view are considered to
      // have the same "invariant view properties."
      true
    }

    public func hash(into _: inout Hasher) { }

    // MARK: Fileprivate

    fileprivate let initialContentAndID: ContentAndID

  }

  public struct ContentAndID: Equatable {

    // MARK: Lifecycle

    // TODO: Remove `id` and rename this type in the next major release.
    public init(content: Content, id _: AnyHashable) {
      self.content = content
    }

    // MARK: Public

    public static func == (_: ContentAndID, _: ContentAndID) -> Bool {
      false
    }

    // MARK: Fileprivate

    fileprivate let content: Content

  }

  public static func makeView(
    withInvariantViewProperties invariantViewProperties: InvariantViewProperties)
    -> SwiftUIWrapperView<Content>
  {
    SwiftUIWrapperView<Content>(contentAndID: invariantViewProperties.initialContentAndID)
  }

  public static func setContent(
    _ contentAndID: ContentAndID,
    on view: SwiftUIWrapperView<Content>)
  {
    view.contentAndID = contentAndID
  }

}
