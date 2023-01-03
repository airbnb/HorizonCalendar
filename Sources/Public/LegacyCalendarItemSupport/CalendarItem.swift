// Created by Bryan Keller on 9/16/19.
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

// MARK: - CalendarItemViewModelEquatable

/// Facilitates the comparison of type-earased `AnyCalendarItem`s based on their concrete types' `viewModel`s.
///
/// - Note: This is a legacy protocol and will be removed in a future major release.
public protocol CalendarItemViewModelEquatable {

  /// Compares the view models of two `CalendarItem`s for equality.
  ///
  /// - Note: There is no reason to invoke this function from your feature code; it should only be invoked internally.
  ///
  /// - Parameters:
  ///   - otherCalendarItem: The calendar item to compare to `self`.
  /// - Returns: `true` if `otherCalendarItem` has the same type as `self` and `otherCalendarItem.viewModel`
  /// equals `self.viewModel`.
  func isViewModel(equalToViewModelOf otherCalendarItem: CalendarItemViewModelEquatable) -> Bool

}

// MARK: - AnyCalendarItem

/// A type-erased calendar item.
///
/// Useful for working with types conforming to `CalendarItem` without knowing the underlying concrete type.
///
/// - Note: This is a legacy protocol and will be removed in a future major release.
public protocol AnyCalendarItem: CalendarItemViewModelEquatable {

  /// A reuse identifier used by `CalendarView` to differentiate between items based on their type and style.
  ///
  /// - Note: There is no reason to access this property from your feature code; it should only be invoked internally.
  var reuseIdentifier: String { get }

  /// Builds an instance of `ViewType` by invoking the `buildView` closure from `CalendarItem`'s initializer.
  ///
  /// - Note: There is no reason to invoke this function from your feature code; it should only be invoked internally.
  func buildView() -> UIView

  /// Updates the view model on an instance of `ViewType` by invoking the `updateViewModel` closure from
  /// `CalendarItem`'s initializer.
  ///
  /// - Note: There is no reason to invoke this function from your feature code; it should only be invoked internally.
  func updateViewModel(view: UIView)

  /// Updates the highlight state on an instance of `ViewType` by invoking the `updateHighlightState` closure from
  /// `CalendarItem`'s initializer.
  ///
  /// - Note: There is no reason to invoke this function from your feature code; it should only be invoked internally.
  func updateHighlightState(view: UIView, isHighlighted: Bool)

}

// MARK: - CalendarItem

/// Represents an item that `CalendarView` will display.
///
/// `CalendarItem`s are what are provided to `CalendarView` via `CalendarViewContent`, and are used to tell
/// `CalendarView` what types of views to display for month headers, day-of-week items, day items, day-range items, and more.
///
/// `CalendarItem` is generic over a `ViewType` and a `ViewModel`.
/// `ViewType` should be a `UIView` or `UIView` subclass, and is what will be displayed  by `CalendarView`.
/// `ViewModel` should be a type that contains all of the data necessary to populate an instance of`ViewType` with data.
///
/// - Warning: This is a legacy type and will be removed in a future major release. Use `CalendarItemModel` instead.
public struct CalendarItem<ViewType, ViewModel>: AnyCalendarItem where
  ViewType: UIView,
  ViewModel: Equatable
{

  // MARK: Lifecycle

  /// Initializes a new `CalendarItem`.
  ///
  /// - Warning: This is a legacy type and will be removed in a future major release. Use `CalendarItemModel` instead.
  ///
  /// - Parameters:
  ///   - viewModel: The view model containing all of the data necessary to populate an instance of`ViewType`.
  ///   - styleID: A string that uniquely identifies anything that makes an instance of  your `ViewType` different that isn't
  ///   captured by the `viewModel`. For example, if you use the same `ViewType` but change its font color, and font color is not a
  ///   property in your `viewModel`, use different `styleID`s for each, which indicates to `CalendarView` that the two views
  ///   are not interchangable / reusable.
  ///   - buildView: A closure (that is retained) to handle the initialization of your `ViewType`.
  ///   - updateViewModel: A closure (that is retained) to handle the updating of your `ViewType`. Use this closure to set the
  ///   view model on your view.
  ///   - updateHighlightState: A closure (that is retained) to handle highlight state changes for your `ViewType`. This
  ///   closure will be invoked when a touch-down event is detected on a day. Leave this unimplemented if your view does not have or
  ///   need a highlight state.
  ///   - view: The view, of type `ViewType`, to be configured with the `viewModel`.
  ///   - isHighlighted: Whether the view should be configured with a highlight state or not.
  public init(
    viewModel: ViewModel,
    styleID: String,
    buildView: @escaping () -> ViewType,
    updateViewModel: @escaping (_ view: ViewType, _ viewModel: ViewModel) -> Void,
    updateHighlightState: ((_ view: ViewType, _ isHighlighted: Bool) -> Void)? = nil)
  {
    self.viewModel = viewModel
    reuseIdentifier = "ViewType: \(String(reflecting: ViewType.self)), styleID: \(styleID)"
    _buildView = buildView
    _updateViewModel = updateViewModel
    _updateHighlightState = updateHighlightState
  }

  // MARK: Public

  /// The view model that represents the data backing your `ViewType`.
  ///
  /// `ViewModel` must conform to `Equatable`; this allows `CalendarView` to differentiate between multiple
  /// `CalendarItem`s, even if those `CalendarItem`s render the same `ViewType`.
  public let viewModel: ViewModel

  public let reuseIdentifier: String

  public func buildView() -> UIView {
    _buildView()
  }

  public func updateViewModel(view: UIView) {
    guard let view = view as? ViewType else {
      preconditionFailure("Failed to convert the UIView to the type-erased ViewType")
    }

    _updateViewModel(view, viewModel)
  }

  public func updateHighlightState(view: UIView, isHighlighted: Bool) {
    guard let view = view as? ViewType else {
      preconditionFailure("Failed to convert the UIView to the type-erased ViewType")
    }

    _updateHighlightState?(view, isHighlighted)
  }

  public func isViewModel(
    equalToViewModelOf otherCalendarItem: CalendarItemViewModelEquatable)
    -> Bool
  {
    guard let otherCalendarItem = otherCalendarItem as? Self else { return false }
    return viewModel == otherCalendarItem.viewModel
  }

  // MARK: Private

  private let _buildView: () -> ViewType
  private let _updateViewModel: (_ view: ViewType, _ viewModel: ViewModel) -> Void
  private let _updateHighlightState: ((_ view: ViewType, _ isHighlighted: Bool) -> Void)?

}
