// Created by Bryan Keller on 2/2/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

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

import CoreGraphics

/// The layout context for an overlaid item, containing information about the location and frame of the item being overlaid, as well as the
/// bounds available to the overlay item for drawing and layout.
public struct OverlayLayoutContext: Hashable {

  /// The location of the item to be overlaid.
  public let overlaidItemLocation: OverlaidItemLocation

  /// The frame of the overlaid item in the coordinate system of `availableBounds`.
  ///
  /// Use this property, in conjunction with `availableBounds`, to prevent your overlay item from laying out outside of the
  /// available bounds.
  public let overlaidItemFrame: CGRect

  /// A rectangle that defines the available region into which the overlay item can be laid out.
  ///
  /// Use this property, in conjunction with `overlaidItemFrame`, to prevent your overlay item from laying out outside of the
  /// available bounds.
  public let availableBounds: CGRect

  public func hash(into hasher: inout Hasher) {
    hasher.combine(overlaidItemLocation)
    hasher.combine(overlaidItemFrame)
    hasher.combine(availableBounds)
  }

}
