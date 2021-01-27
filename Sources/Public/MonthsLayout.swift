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
  /// - `options`: Additional options to adjust the layout of the horizontally-scrolling calendar.
  case horizontal(options: HorizontalMonthsLayoutOptions)

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
  
  var isPaginationEnabled: Bool {
    guard
      case .horizontal(let options) = self,
      case .paginatedScrolling = options.scrollingBehavior
    else
    {
      return false
    }

    return true
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

  /// Calendar months will be arranged in a single row, and scroll on the horizontal axis.
  ///
  /// - `monthWidth`: The width of each month.
  @available(
    *,
    deprecated,
    message: "Use .horizontal(options: HorizontalMonthsLayoutOptions) instead. This will be removed in a future major release.")
  public static func horizontal(monthWidth: CGFloat) -> Self {
    var options = HorizontalMonthsLayoutOptions(scrollingBehavior: .freeScrolling)
    options.monthWidth = monthWidth
    return .horizontal(options: options)
  }

}

// MARK: Equatable

extension MonthsLayout: Equatable {

  public static func == (lhs: MonthsLayout, rhs: MonthsLayout) -> Bool {
    switch (lhs, rhs)  {
    case (.vertical(let lhsOptions), .vertical(let rhsOptions)): return lhsOptions == rhsOptions
    case (.horizontal(let lhsOptions), .horizontal(let rhsOptions)): return lhsOptions == rhsOptions
    default: return false
    }
  }

}

// MARK: - VerticalMonthsLayoutOptions

/// Layout options for a vertically-scrolling calendar.
public struct VerticalMonthsLayoutOptions: Equatable {

  // MARK: Lifecycle

  /// Initializes a new instance of `VerticalMonthsLayoutOptions`.
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

// MARK: - HorizontalMonthsLayoutOptions

/// Layout options for a horizontally-scrolling calendar.
public struct HorizontalMonthsLayoutOptions: Equatable {

  // MARK: Lifecycle

  /// Initializes a new instance of `HorizontalMonthsLayoutOptions`.
  ///
  /// - Parameters:
  ///   - maximumFullyVisibleMonths: The maximum number of fully visible months for any scroll offset. The default value is
  ///   `1`.
  ///   - scrollingBehavior: The scrolling behavior of the horizontally-scrolling calendar: either paginated-scrolling or
  ///   free-scrolling. The default value is paginated-scrolling by month.
  public init(
    maximumFullyVisibleMonths: Double = 1,
    scrollingBehavior: ScrollingBehavior = .paginatedScrolling(
      .init(
        restingPosition: .atIncrementsOfCalendarWidth,
        restingAffinity: .atPositionsAdjacentToPrevious)))
  {
    assert(maximumFullyVisibleMonths >= 1, "`maximumFullyVisibleMonths` must be greater than 1.")
    self.maximumFullyVisibleMonths = maximumFullyVisibleMonths
    self.scrollingBehavior = scrollingBehavior
  }

  // MARK: Public

  /// The maximum number of fully visible months for any scroll offset.
  public let maximumFullyVisibleMonths: Double

  /// The scrolling behavior of the horizontally-scrolling calendar: either paginated-scrolling or free-scrolling.
  public let scrollingBehavior: ScrollingBehavior

  // MARK: Internal

  /// This property exists only to support `MonthsLayout.horizontal(monthWidth: CGFloat)`, which is deprecated.
  var monthWidth: CGFloat?

  func monthWidth(calendarWidth: CGFloat, interMonthSpacing: CGFloat) -> CGFloat {
    if let monthWidth = monthWidth {
      return monthWidth
    }

    let visibleInterMonthSpacing = CGFloat(maximumFullyVisibleMonths) * interMonthSpacing
    return (calendarWidth - visibleInterMonthSpacing) / CGFloat(maximumFullyVisibleMonths)
  }
  
  func pageSize(calendarWidth: CGFloat, interMonthSpacing: CGFloat) -> CGFloat {
    guard case .paginatedScrolling(let configuration) = scrollingBehavior else {
      preconditionFailure(
        "Cannot get a page size for a calendar that does not have horizontal pagination enabled.")
    }
    
    switch configuration.restingPosition {
    case .atIncrementsOfCalendarWidth:
      return calendarWidth
    case .atLeadingEdgeOfEachMonth:
      let monthWidth = self.monthWidth(
        calendarWidth: calendarWidth,
        interMonthSpacing: interMonthSpacing)
      return monthWidth + interMonthSpacing
    }
  }

}

// MARK: - HorizontalMonthsLayoutOptions.ScrollingBehavior

extension HorizontalMonthsLayoutOptions {
  
  /// The scrolling behavior of the horizontally-scrolling calendar: either paginated-scrolling or free-scrolling.
  public enum ScrollingBehavior: Equatable {
    
    /// The calendar will come to a rest at specific scroll positions, defined by the `PaginationConfiguration`.
    case paginatedScrolling(PaginationConfiguration)
    
    /// The calendar will come to a rest at any scroll position.
    case freeScrolling
  }

}

// MARK: - HorizontalMonthsLayoutOptions.PaginationConfiguration

extension HorizontalMonthsLayoutOptions {
  
  /// The pagination behavior's configurable options.
  public struct PaginationConfiguration: Equatable {
    
    // MARK: Lifecycle
    
    public init(restingPosition: RestingPosition, restingAffinity: RestingAffinity) {
      self.restingPosition = restingPosition
      self.restingAffinity = restingAffinity
    }
    
    // MARK: Public
    
    /// The position at which the calendar will come to a rest when paginating.
    public let restingPosition: RestingPosition
    
    /// The calendar's affinity for stopping at a resting position.
    public let restingAffinity: RestingAffinity

  }
  
}

extension HorizontalMonthsLayoutOptions.PaginationConfiguration {
  
  // MARK: - HorizontalMonthsLayoutOptions.PaginationConfiguration.RestingPosition
  
  /// The position at which the calendar will come to a rest when paginating.
  public enum RestingPosition: Equatable {

    /// The calendar will come to a rest at the leading edge of each month.
    case atLeadingEdgeOfEachMonth

    /// The calendar will come to a rest at increments equal to the calendar's width.
    case atIncrementsOfCalendarWidth

  }
  
  // MARK: - HorizontalMonthsLayoutOptions.PaginationConfiguration.RestingAffinity
  
  /// The calendar's affinity for stopping at a resting position.
  public enum RestingAffinity: Equatable {
    
    /// The calendar will come to a rest at the position adjacent to the previous resting position, regardless of how fast the user
    /// swipes.
    case atPositionsAdjacentToPrevious
    
    /// The calendar will come to a rest at the closest position to the target scroll offset, potentially skipping over many valid resting
    /// positions depending on how fast the user swipes.
    case atPositionsClosestToTargetOffset

  }
  
}
