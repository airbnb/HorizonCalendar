// Created by Bryan Keller on 5/31/20.
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

import Foundation

// MARK: - DayRange

public typealias DayRange = ClosedRange<Day>

extension DayRange {

  // MARK: Lifecycle

  /// Instantiates a `DayRange` that encapsulates the `dateRange` in the `calendar` as closely as possible. For example,
  /// a date range of [2020-05-20T23:59:59, 2021-01-01T00:00:00] will result in a day range of [2020-05-20, 2021-01-01].
  init(containing dateRange: ClosedRange<Date>, in calendar: Calendar) {
    self.init(
      uncheckedBounds: (
        lower: calendar.day(containing: dateRange.lowerBound),
        upper: calendar.day(containing: dateRange.upperBound)))
  }

}
