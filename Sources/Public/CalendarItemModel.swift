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

  /// Initializes a new `CalendarItemModel`.
  ///
  /// - Parameters:
  ///   - invariantViewProperties: A type containing all of the immutable / view-model-independent properties necessary to
  ///   initialize a `ViewType`. Use this to configure appearance options that do not change based on the data in the `viewModel`.
  ///   For example, you might pass a type that contains properties to configure a `UILabel`'s `textAlignment`, `textColor`,
  ///   and `font`, assuming none of those things change in response to `viewModel` updates.
  ///   - viewModel: A type containing all of the variable data necessary to update an instance of`ViewType`. Use this to specify
  ///   the dynamic, data-driven parts of the view.
  public init(
    invariantViewProperties: ViewRepresentable.InvariantViewProperties,
    viewModel: ViewRepresentable.ViewModel)
  {
    _itemViewDifferentiator = .viewRepresentable(
      viewRepresentableTypeDescription: String(reflecting: ViewRepresentable.self),
      viewTypeDescription: String(reflecting: ViewRepresentable.ViewType.self),
      invariantViewProperties: invariantViewProperties)

    self.invariantViewProperties = invariantViewProperties
    self.viewModel = viewModel
  }

  // MARK: Public

  public let _itemViewDifferentiator: _CalendarItemViewDifferentiator

  public func _makeView() -> UIView {
    ViewRepresentable.makeView(withInvariantViewProperties: invariantViewProperties)
  }

  public func _setViewModel(onViewOfSameType view: UIView) {
    guard let view = view as? ViewRepresentable.ViewType else {
      let viewTypeDescription = String(reflecting: ViewRepresentable.ViewType.self)
      preconditionFailure("Failed to convert the view to an instance of \(viewTypeDescription).")
    }

    ViewRepresentable.setViewModel(viewModel, on: view)
  }

  public func _isViewModel(equalToViewModelOf other: AnyCalendarItemModel) -> Bool {
    guard let other = other as? Self else {
      let selfTypeDescription = String(reflecting: Self.self)
      preconditionFailure(
        "Failed to convert the calendar item model to an instance of \(selfTypeDescription).")
    }

    return viewModel == other.viewModel
  }

  // MARK: Private

  private let invariantViewProperties: ViewRepresentable.InvariantViewProperties
  private let viewModel: ViewRepresentable.ViewModel

}
