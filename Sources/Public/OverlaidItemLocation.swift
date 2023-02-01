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

import Foundation

/// Represents the location of an item that can be overlaid.
public enum OverlaidItemLocation: Hashable {

  /// A month header location that can be overlaid.
  ///
  /// The particular month to be overlaid is specified with a `Date` instance, which will be used to determine the associated month
  /// using the `calendar` instance with which `CalendarViewContent` was instantiated.
  case monthHeader(monthContainingDate: Date)

  /// A day location that can be overlaid.
  ///
  /// The particular day to be overlaid is specified with a `Date` instance, which will be used to determine the associated day using
  /// the `calendar` instance with which `CalendarViewContent` was instantiated.
  case day(containingDate: Date)
}
