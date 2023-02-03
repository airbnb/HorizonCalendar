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
/// `content`, simplifying the initialization and state updating of views.
public protocol CalendarItemViewRepresentable {

  /// The type of view that this `CalendarItemViewRepresentable` can create and update.
  associatedtype ViewType: UIView

  /// A type containing all of the immutable / initial setup values necessary to initialize the view. Use this to configure appearance
  /// options that do not change based on the data in the `content`.
  associatedtype InvariantViewProperties: Hashable

  /// A type containing all of the variable data necessary to update the view. Use this to update the dynamic, data-driven parts of the
  /// view.
  ///
  /// If your view does not depend on any variable data, then `Content` can be `Never` and `setContent(_:on)` does not
  /// need to be implemented. This is not common, since most views used in the calendar change what they display based on the
  /// parameters passed into the `*itemProvider*` closures (e.g. the current day, month, or day range layout context information).
  associatedtype Content: Equatable = Never

  /// Creates a view using a set of invariant view properties that contain all of the immutable / initial setup values necessary to
  /// configure the view. All immutable / view-model-independent properties should be configured here. For example, you might set up
  /// a `UILabel`'s `textAlignment`, `textColor`, and `font`, assuming none of those properties change in response to
  /// `content` updates.
  ///
  /// - Parameters:
  ///   - invariantViewProperties: An instance containing all of the immutable / initial setup values necessary to initialize the
  ///   view. Use this to configure appearance options that do not change based on the data in the `content`.
  static func makeView(
    withInvariantViewProperties invariantViewProperties: InvariantViewProperties)
    -> ViewType

  /// Sets the content on your view. `CalendarView` invokes this whenever a view's data is stale and needs to be updated to
  /// reflect the data in a new content instance.
  ///
  /// - Parameters:
  ///   - content: An instance containing all of the variable data necessary to update the view.
  static func setContent(_ content: Content, on view: ViewType)

}

extension CalendarItemViewRepresentable where Content == Never {
  public static func setContent(_: Content, on _: ViewType) { }
}
