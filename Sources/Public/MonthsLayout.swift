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
  /// - `options`: Additional options to adjust the layout of the vertically-scrolling calendar.
  case vertical(options: VerticalMonthsLayoutOptions)

  /// Calendar months will be arranged in a single row, and scroll on the horizontal axis.
  ///
  /// - `monthWidth`: Whether the days of the week will appear once, pinned at the top, or separately for each
  /// month.
  case horizontal(monthWidth: CGFloat)

  // MARK: Internal

  var isHorizontal: Bool {
    switch self {
    case .vertical: return false
    case .horizontal: return true
    }
  }

  var pinDaysOfWeekToTop: Bool {
    switch self {
    case .vertical(let options): return options.pinDaysOfWeekToTop
    case .horizontal: return false
    }
  }

  var alwaysShowCompleteBoundaryMonths: Bool {
    switch self {
    case .vertical(let options): return options.alwaysShowCompleteBoundaryMonths
    case .horizontal: return true
    }
  }
}

// MARK: Deprecated

extension MonthsLayout {

  /// Calendar months will be arranged in a single column, and scroll on the vertical axis.
  ///
  /// - `pinDaysOfWeekToTop`: Whether the days of the week will appear once, pinned at the top, or separately for each month.
  @available(
    *,
    deprecated,
    message: "Use .vertical(options: VerticalMonthsLayoutOptions) instead. This will be removed in a future major release.")
  public static func vertical(pinDaysOfWeekToTop: Bool) -> Self {
    let options = VerticalMonthsLayoutOptions(pinDaysOfWeekToTop: pinDaysOfWeekToTop)
    return .vertical(options: options)
  }

}

// MARK: Equatable

extension MonthsLayout: Equatable {

  public static func == (lhs: MonthsLayout, rhs: MonthsLayout) -> Bool {
    switch (lhs, rhs)  {
    case (.vertical(let lhsOptions), .vertical(let rhsOptions)): return lhsOptions == rhsOptions
    case (.horizontal, .horizontal): return true
    default: return false
    }
  }

}

// MARK: - VerticalMonthsLayoutOptions

/// Layout options for a vertically-scrolling calendar.
public struct VerticalMonthsLayoutOptions: Equatable {

  // MARK: Lifecycle

  /// Initialized a new instance of `VerticalMonthsLayoutOptions`.
  ///
  /// - Parameters:
  ///   - pinDaysOfWeekToTop: Whether the days of the week will appear once, pinned at the top, or repeatedly in each month.
  ///   The default value is `false`.
  ///   - alwaysShowCompleteBoundaryMonths: Whether the calendar will always show complete months, even if the visible
  ///   date range does not start on the first date or end on the last date of a month. The default value is `true`.
  public init(pinDaysOfWeekToTop: Bool = false, alwaysShowCompleteBoundaryMonths: Bool = true) {
    self.pinDaysOfWeekToTop = pinDaysOfWeekToTop
    self.alwaysShowCompleteBoundaryMonths = alwaysShowCompleteBoundaryMonths
  }

  // MARK: Public

  /// Whether the days of the week will appear once, pinned at the top, or repeatedly in each month.
  public let pinDaysOfWeekToTop: Bool

  /// Whether the calendar will always show complete months at the calendar's boundaries, even if the visible date range does not start
  /// on the first date or end on the last date of a month.
  public let alwaysShowCompleteBoundaryMonths: Bool

}
