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
///
/// - Warning: Using a SwiftUI view with the calendar will cause `SwiftUIView.HostingController`(s) to be added to the
/// closest view controller in the responder chain in relation to the `CalendarView`.
@available(iOS 13.0, *)
public final class SwiftUIWrapperView<Content: View>: UIView {

  // MARK: Lifecycle

  public init(contentAndID: ContentAndID) {
    self.contentAndID = contentAndID
    hostingController = HostingController(
      rootView: .init(content: contentAndID.content, id: contentAndID.id))

    super.init(frame: .zero)

    insetsLayoutMarginsFromSafeArea = false
    layoutMargins = .zero
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public override var isAccessibilityElement: Bool {
    get { false }
    set { }
  }

  public override func didMoveToWindow() {
    super.didMoveToWindow()

    if window != nil {
      setUpHostingControllerIfNeeded()
    }
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    hostingControllerView?.frame = bounds
  }

  public override func systemLayoutSizeFitting(
    _ targetSize: CGSize,
    withHorizontalFittingPriority _: UILayoutPriority,
    verticalFittingPriority _: UILayoutPriority)
    -> CGSize
  {
    hostingController.sizeThatFits(in: targetSize)
  }

  // MARK: Fileprivate

  fileprivate var contentAndID: ContentAndID {
    didSet {
      hostingController.rootView = .init(content: contentAndID.content, id: contentAndID.id)
      configureGestureRecognizers()
    }
  }

  // MARK: Private

  private let hostingController: HostingController<IDWrapperView<Content>>

  private weak var hostingControllerView: UIView?

  private func setUpHostingControllerIfNeeded() {
    guard let closestViewController = closestViewController() else {
      assertionFailure(
        "Could not find a view controller to which the `UIHostingController` could be added.")
      return
    }

    guard hostingController.parent !== closestViewController else { return }

    if hostingController.parent != nil {
      hostingController.willMove(toParent: nil)
      hostingController.view.removeFromSuperview()
      hostingController.removeFromParent()
      hostingController.didMove(toParent: nil)
    }

    hostingController.willMove(toParent: closestViewController)
    closestViewController.addChild(hostingController)
    hostingControllerView = hostingController.view
    addSubview(hostingController.view)
    hostingController.didMove(toParent: closestViewController)

    setNeedsLayout()
  }

  // This allows touches to be passed to `ItemView` even if the SwiftUI `View` has a gesture
  // recognizer.
  private func configureGestureRecognizers() {
    for gestureRecognizer in hostingControllerView?.gestureRecognizers ?? [] {
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

  public struct ContentAndID: Equatable, SwiftUIWrapperViewContentIDUpdatable {

    // MARK: Lifecycle

    public init(content: Content, id: AnyHashable) {
      self.content = content
      self.id = id
    }

    // MARK: Public

    public static func == (_: ContentAndID, _: ContentAndID) -> Bool {
      false
    }

    // MARK: Internal

    var id: AnyHashable

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

// MARK: - SwiftUIWrapperViewContentIDUpdatable

protocol SwiftUIWrapperViewContentIDUpdatable {
  var id: AnyHashable { get set }
}

// MARK: UIResponder Next View Controller Helper

extension UIResponder {
  /// Recursively traverses up the responder chain to find the closest view controller.
  fileprivate func closestViewController() -> UIViewController? {
    self as? UIViewController ?? next?.closestViewController()
  }
}

// MARK: - IDWrapperView

/// A wrapper view that uses the `id(_:)` modifier on the wrapped view so that each one has its own identity, even if it was reused.
@available(iOS 13.0, *)
private struct IDWrapperView<Content: View>: View {

  let content: Content
  let id: AnyHashable

  var body: some View {
    content
      .id(id)
  }

}

// MARK: - HostingController

/// The `UIHostingController` type used by `SwiftUIWrapperView` to embed SwiftUI views in a UIKit view hierarchy. This
/// exists to disable safe area insets and set the background color to clear.
@available(iOS 13.0, *)
private final class HostingController<Content: View>: UIHostingController<Content> {

  // MARK: Lifecycle

  override init(rootView: Content) {
    super.init(rootView: rootView)

    // This prevents the safe area from affecting layout.
    _disableSafeArea = true
  }

  @MainActor
  required dynamic init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()

    // Override the default `.systemBackground` color since `CalendarView` subviews should be
    // clear.
    view.backgroundColor = .clear
  }

}
