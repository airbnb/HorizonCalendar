// Created by Bryan Keller on 7/15/20.
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

import SwiftUI
import UIKit

// MARK: - CalendarItemModel

/// Represents a view that `CalendarView` will display at a particular location.
///
/// `CalendarItemModel`s are what are provided to `CalendarView` via `CalendarViewContent`, and are used to tell
/// `CalendarView` what types of views to display for month headers, day-of-week items, day items, day-range items, and more.
///
/// `CalendarItemModel` is generic over a `ViewRepresentable`, a type that can create and update the represented view.
/// See the documentation for `CalendarItemViewRepresentable` for more details.
public struct CalendarItemModel<ViewRepresentable>: AnyCalendarItemModel where
  ViewRepresentable: CalendarItemViewRepresentable
{

  // MARK: Lifecycle

  /// Initializes a new `CalendarItemModel` that can be returned from the various item-provider `CalendarViewContent`
  /// closures.
  ///
  /// - Parameters:
  ///   - invariantViewProperties: A type containing all of the immutable / view-model-independent properties necessary to
  ///   initialize a `ViewType`. Use this to configure appearance options that do not change based on the data in the `content`.
  ///   For example, you might pass a type that contains properties to configure a `UILabel`'s `textAlignment`, `textColor`,
  ///   and `font`, assuming none of those values change in response to `content` updates.
  ///   - content: A type containing all of the variable data necessary to update an instance of `ViewType`. Use this to specify
  ///   the dynamic, data-driven parts of the view.
  public init(
    invariantViewProperties: ViewRepresentable.InvariantViewProperties,
    content: ViewRepresentable.Content)
  {
    _itemViewDifferentiator = _CalendarItemViewDifferentiator(
      viewType: ObjectIdentifier(ViewRepresentable.self),
      invariantViewProperties: invariantViewProperties)

    self.invariantViewProperties = invariantViewProperties
    self.content = content
  }

  // MARK: Public

  public let _itemViewDifferentiator: _CalendarItemViewDifferentiator

  public func _makeView() -> UIView {
    ViewRepresentable.makeView(withInvariantViewProperties: invariantViewProperties)
  }

  public func _setContent(onViewOfSameType view: UIView) {
    guard let content else { return }
    guard let view = view as? ViewRepresentable.ViewType else {
      let viewTypeDescription = String(reflecting: ViewRepresentable.ViewType.self)
      preconditionFailure("Failed to convert the view to an instance of \(viewTypeDescription).")
    }

    ViewRepresentable.setContent(content, on: view)
  }

  public func _isContentEqual(toContentOf other: AnyCalendarItemModel) -> Bool {
    guard let other = other as? Self else {
      let selfTypeDescription = String(reflecting: Self.self)
      preconditionFailure(
        "Failed to convert the calendar item model to an instance of \(selfTypeDescription).")
    }

    return content == other.content
  }

  public mutating func _setSwiftUIWrapperViewContentIDIfNeeded(_: AnyHashable) { }

  // MARK: Private

  private let invariantViewProperties: ViewRepresentable.InvariantViewProperties

  // This is only mutable because we need to update the ID for `SwiftUIWrapperView`'s content.
  private var content: ViewRepresentable.Content?

}

extension CalendarItemModel where ViewRepresentable.Content == Never {

  /// Initializes a new `CalendarItemModel` that does not depend on any variable data, and can be returned from the various
  /// item-provider `CalendarViewContent` closures. If there is variable data to pass into this view, such as the current day, use
  /// `init(invariantViewProperties:content:)` instead, and pass your data in via the `content` parameter.
  ///
  /// - Parameters:
  ///   - invariantViewProperties: A type containing all of the immutable / view-model-independent properties necessary to
  ///   initialize a `ViewType`. Use this to configure appearance options that do not change based on the data in the `content`.
  ///   For example, you might pass a type that contains properties to configure a `UILabel`'s `textAlignment`, `textColor`,
  ///   and `font`, assuming none of those values change in response to `content` updates.
  public init(invariantViewProperties: ViewRepresentable.InvariantViewProperties) {
    _itemViewDifferentiator = _CalendarItemViewDifferentiator(
      viewType: ObjectIdentifier(ViewRepresentable.self),
      invariantViewProperties: invariantViewProperties)

    self.invariantViewProperties = invariantViewProperties
    content = nil
  }

}

// MARK: UIKit Convenience Factory

extension CalendarItemViewRepresentable {

  /// Creates a `CalendarItemModel` that can be returned from the various item-provider `CalendarViewContent` closures.
  ///
  /// - Parameters:
  ///   - invariantViewProperties: A type containing all of the immutable / view-model-independent properties necessary to
  ///   initialize a `ViewType`. Use this to configure appearance options that do not change based on the data in the `content`.
  ///   For example, you might pass a type that contains properties to configure a `UILabel`'s `textAlignment`, `textColor`,
  ///   and `font`, assuming none of those values change in response to `content` updates.
  ///   - content: A type containing all of the variable data necessary to update an instance of `ViewType`. Use this to specify
  ///   the dynamic, data-driven parts of the view.
  public static func calendarItemModel(
    invariantViewProperties: InvariantViewProperties,
    content: Content)
    -> CalendarItemModel<Self>
  {
    CalendarItemModel<Self>(invariantViewProperties: invariantViewProperties, content: content)
  }

}

extension CalendarItemViewRepresentable where Content == Never {

  /// Creates a `CalendarItemModel` that does not depend on any variable data, and can be returned from the various
  /// item-provider `CalendarViewContent` closures. If there is variable data to pass into this view, such as the current day, use
  /// `calendarItemModel(invariantViewProperties:content:)` instead, and pass your data in via the `content`
  /// parameter.
  ///
  /// - Parameters:
  ///   - invariantViewProperties: A type containing all of the immutable / view-model-independent properties necessary to
  ///   initialize a `ViewType`. Use this to configure appearance options that do not change based on the data in the `content`.
  ///   For example, you might pass a type that contains properties to configure a `UILabel`'s `textAlignment`, `textColor`,
  ///   and `font`, assuming none of those values change in response to `content` updates.
  public static func calendarItemModel(
    invariantViewProperties: InvariantViewProperties)
    -> CalendarItemModel<Self>
  {
    CalendarItemModel<Self>(invariantViewProperties: invariantViewProperties)
  }

}

// MARK: SwiftUI Convenience Factory

@available(iOS 13.0, *)
extension View {

  /// Creates a `CalendarItemModel` from a SwiftUI `View`.
  ///
  /// This is equivalent to manually creating a
  /// `CalendarItemModel<SwiftUIWrapperView<YourView>>`, where `YourView` is some SwiftUI `View`.
  public var calendarItemModel: CalendarItemModel<SwiftUIWrapperView<Self>> {
    let contentAndID = SwiftUIWrapperView.ContentAndID(content: self, id: 0)
    return CalendarItemModel<SwiftUIWrapperView<Self>>(
      invariantViewProperties: .init(initialContentAndID: contentAndID),
      content: contentAndID)
  }

}
