// Created by Bryan Keller on 9/18/19.
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

import CoreGraphics

// MARK: - MonthsLayout

/// The layout of months displayed in `CalendarView`.
public enum MonthsLayout {

  /// Calendar months will be arranged in a single column, and scroll on the vertical axis.
  ///
  /// - `pinDaysOfWeekToTop`: Whether the days of the week will appear once, pinned at the top, or separately for each
  /// month.
  case vertical(pinDaysOfWeekToTop: Bool)

  /// Calendar months will be arranged in a single row, and scroll on the horizontal axis.
  ///
  /// - `monthWidth`: Whether the days of the week will appear once, pinned at the top, or separately for each
  /// month.
  case horizontal(monthWidth: CGFloat)

  // MARK: Internal

  var pinDaysOfWeekToTop: Bool {
    switch self {
    case .vertical(let pinDaysOfWeekToTop): return pinDaysOfWeekToTop
    case .horizontal: return false
    }
  }
}

// MARK: Equatable

extension MonthsLayout: Equatable {

  public static func == (lhs: MonthsLayout, rhs: MonthsLayout) -> Bool {
    switch (lhs, rhs)  {
    case (.horizontal, .horizontal): return true
    case (.vertical(let l), .vertical(let r)): return l == r
    default: return false
    }
  }

}
