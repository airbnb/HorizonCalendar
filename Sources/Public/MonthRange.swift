// Created by Bryan Keller on 5/30/20.
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

// MARK: - MonthRange

public typealias MonthRange = ClosedRange<Month>

extension MonthRange {

  // MARK: Lifecycle

  /// Instantiates a `MonthRange` that encapsulates the `dateRange` in the `calendar` as closely as possible. For example,
  /// a date range of [2020-01-19, 2021-02-01] will result in a month range of [2020-01, 2021-02].
  init(containing dateRange: ClosedRange<Date>, in calendar: Calendar) {
    self.init(
      uncheckedBounds: (
        lower: calendar.month(containing: dateRange.lowerBound),
        upper: calendar.month(containing: dateRange.upperBound)))
  }

}
