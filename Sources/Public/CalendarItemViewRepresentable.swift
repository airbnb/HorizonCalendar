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

// MARK: - CalendarItemViewRepresentable

/// A protocol to which types that can create and update views displayed in `CalendarView` must conform. By conforming to this
/// protocol, `CalendarView` is able to treat each view it displays as a function of its `invariantViewProperties` and its
/// `viewModel`, simplifying the initialization and state updating of views.
public protocol CalendarItemViewRepresentable {

  /// The type of view that this `CalendarItemViewRepresentable` can create and update.
  associatedtype ViewType: UIView

  /// A type containing all of the immutable / initial setup values necessary to initialize the view. Use this to configure appearance
  /// options that do not change based on the data in the `viewModel`.
  associatedtype InvariantViewProperties: Hashable

  /// A type containing all of the variable data necessary to update the view. Use this to update the dynamic, data-driven parts of the
  /// view.
  associatedtype ViewModel: Equatable

  /// Creates a view using a set of invariant view properties that contain all of the immutable / initial setup values necessary to
  /// configure the view. All immutable / view-model-independent properties should be configured here. For example, you might set up
  /// a `UILabel`'s `textAlignment`, `textColor`, and `font`, assuming none of those properties change in response to
  /// `viewModel` updates.
  ///
  /// - Parameters:
  ///   - invariantViewProperties: An instance containing all of the immutable / initial setup values necessary to initialize the
  ///   view. Use this to configure appearance options that do not change based on the data in the `viewModel`.
  static func makeView(
    withInvariantViewProperties invariantViewProperties: InvariantViewProperties)
    -> ViewType

  /// Sets the view model on your view. `CalendarView` invokes this whenever a view's data is stale and needs to be updated to
  /// reflect the data in a new view model.
  ///
  /// - Parameters:
  ///   - viewModel: An instance containing all of the variable data necessary to update the view.
  static func setViewModel(_ viewModel: ViewModel, on view: ViewType)

}
