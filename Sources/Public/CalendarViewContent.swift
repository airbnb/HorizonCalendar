// Created by Bryan Keller on 9/16/19.
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

// MARK: - CalendarViewContent

/// The content that `CalendarView` renders.
///
/// `CalendarViewContent` must be initialized with a `Calendar`, a date range that will be used to determine the total month
/// range to display, and a months layout to indicate whether months should be laid out vertically or horizontally. All other properties
/// have default values.
public final class CalendarViewContent {

  // MARK: Lifecycle

  /// Initializes a new `CalendarViewContent` with default `CalendarItemModel` providers.
  ///
  /// - Parameters:
  ///   - calendar: The calendar on which all date operations will be performed. Defaults to `Calendar.current` (the system's
  ///   current calendar).
  ///   - visibleDateRange: The date range that will be displayed. The dates in this range are interpreted using the provided
  ///   `calendar`.
  ///   - monthsLayout: The layout of months - either vertically or horizontally.
  public init(
    calendar: Calendar = Calendar.current,
    visibleDateRange: ClosedRange<Date>,
    monthsLayout: MonthsLayout)
  {
    self.calendar = calendar
    monthRange = MonthRange(containing: visibleDateRange, in: calendar)
    self.monthsLayout = monthsLayout

    let exactDayRange = DayRange(containing: visibleDateRange, in: calendar)
    if monthsLayout.alwaysShowCompleteBoundaryMonths {
      let firstDateOfLowerBoundMonth = calendar.firstDate(of: monthRange.lowerBound)
      let lastDateOfUpperBoundMonth = calendar.lastDate(of: monthRange.upperBound)
      dayRange = DayRange(
        containing: firstDateOfLowerBoundMonth...lastDateOfUpperBoundMonth,
        in: calendar)
    } else {
      dayRange = exactDayRange
    }

    let monthHeaderDateFormatter = DateFormatter()
    monthHeaderDateFormatter.calendar = calendar
    monthHeaderDateFormatter.locale = calendar.locale
    monthHeaderDateFormatter.dateFormat = DateFormatter.dateFormat(
      fromTemplate: "MMMM yyyy",
      options: 0,
      locale: calendar.locale ?? Locale.current)

    monthHeaderItemProvider = { month in
      let firstDateInMonth = calendar.firstDate(of: month)
      let monthText = monthHeaderDateFormatter.string(from: firstDateInMonth)
      let itemModel = MonthHeaderView.calendarItemModel(
        invariantViewProperties: .base,
        content: .init(monthText: monthText, accessibilityLabel: monthText))
      return itemModel
    }

    dayOfWeekItemProvider = { _, weekdayIndex in
      let dayOfWeekText = monthHeaderDateFormatter.veryShortStandaloneWeekdaySymbols[weekdayIndex]
      let itemModel = DayOfWeekView.calendarItemModel(
        invariantViewProperties: .base,
        content: .init(dayOfWeekText: dayOfWeekText, accessibilityLabel: dayOfWeekText))
      return itemModel
    }

    let dayDateFormatter = DateFormatter()
    dayDateFormatter.calendar = calendar
    dayDateFormatter.locale = calendar.locale
    dayDateFormatter.dateFormat = DateFormatter.dateFormat(
      fromTemplate: "EEEE, MMM d, yyyy",
      options: 0,
      locale: calendar.locale ?? Locale.current)

    dayItemProvider = { day in
      let date = calendar.startDate(of: day)
      let itemModel = DayView.calendarItemModel(
        invariantViewProperties: .baseNonInteractive,
        content: .init(
          dayText: "\(day.day)",
          accessibilityLabel: dayDateFormatter.string(from: date),
          accessibilityHint: nil))
      return itemModel
    }
  }

  // MARK: Public

  /// Configures the aspect ratio of each day.
  ///
  /// Values less than 1 will result in rectangular days that are wider than they are tall. Values
  /// greater than 1 will result in rectangular days that are taller than they are wide. The default value is `1`, which results in square
  /// views with the same width and height.
  ///
  /// - Parameters:
  ///   - dayAspectRatio: The aspect ratio of each day view.
  /// - Returns: A mutated `CalendarViewContent` instance with a new day aspect ratio value.
  public func dayAspectRatio(_ dayAspectRatio: CGFloat) -> CalendarViewContent {
    let validAspectRatioRange: ClosedRange<CGFloat> = 0.5...3
    assert(
      validAspectRatioRange.contains(dayAspectRatio),
      "A day aspect ratio of \(dayAspectRatio) will likely cause strange calendar layouts. Only values between \(validAspectRatioRange.lowerBound) and \(validAspectRatioRange.upperBound) should be used.")
    self.dayAspectRatio = min(
      max(dayAspectRatio, validAspectRatioRange.lowerBound),
      validAspectRatioRange.upperBound)
    return self
  }

  /// Configures the aspect ratio of each day of the week.
  ///
  /// Values less than 1 will result in rectangular days of the week that are wider than they are tall. Values
  /// greater than 1 will result in rectangular days of the week that are taller than they are wide. The default value is `1`, which results
  /// in square views with the same width and height.
  ///
  /// - Parameters:
  ///   - dayOfWeekAspectRatio: The aspect ratio of each day-of-the-week view.
  /// - Returns: A mutated `CalendarViewContent` instance with a new day-of-the-week aspect ratio value.
  public func dayOfWeekAspectRatio(_ dayOfWeekAspectRatio: CGFloat) -> CalendarViewContent {
    let validAspectRatioRange: ClosedRange<CGFloat> = 0.5...3
    assert(
      validAspectRatioRange.contains(dayOfWeekAspectRatio),
      "A day-of-the-week aspect ratio of \(dayOfWeekAspectRatio) will likely cause strange calendar layouts. Only values between \(validAspectRatioRange.lowerBound) and \(validAspectRatioRange.upperBound) should be used.")
    self.dayOfWeekAspectRatio = min(
      max(dayOfWeekAspectRatio, validAspectRatioRange.lowerBound),
      validAspectRatioRange.upperBound)
    return self
  }

  /// Configures the amount of spacing, in points, between months. The default value is `0`.
  ///
  /// - Parameters:
  ///   - interMonthSpacing: The amount of spacing, in points, between months.
  /// - Returns: A mutated `CalendarViewContent` instance with a new inter-month-spacing value.
  public func interMonthSpacing(_ interMonthSpacing: CGFloat) -> CalendarViewContent {
    self.interMonthSpacing = interMonthSpacing
    return self
  }

  /// Configures the amount to inset days and day-of-week items from the edges of a month. The default value is `.zero`.
  ///
  /// - Parameters:
  ///   - monthDayInsets: The amount to inset days and day-of-week items from the edges of a month.
  /// - Returns: A mutated `CalendarViewContent` instance with a new month-day-insets value.
  public func monthDayInsets(_ monthDayInsets: NSDirectionalEdgeInsets) -> CalendarViewContent {
    self.monthDayInsets = monthDayInsets
    return self
  }

  /// Configures the amount of space between two day frames vertically.
  ///
  /// If `verticalDayMargin` and `horizontalDayMargin` are the same, then each day will appear to
  /// have a 1:1 (square) aspect ratio. If `verticalDayMargin` and `horizontalDayMargin` are different, then days can
  /// appear wider or taller.
  ///
  /// - Parameters:
  ///   - verticalDayMargin: The amount of space between two day frames along the vertical axis.
  /// - Returns: A mutated `CalendarViewContent` instance with a new vertical day margin value.
  public func verticalDayMargin(_ verticalDayMargin: CGFloat) -> CalendarViewContent {
    self.verticalDayMargin = verticalDayMargin
    return self
  }

  /// Configures the amount of space between two day frames horizontally.
  ///
  /// If `verticalDayMargin` and `horizontalDayMargin` are the same, then each day will appear to
  /// have a 1:1 (square) aspect ratio. If `verticalDayMargin` and `horizontalDayMargin` are
  /// different, then days can appear wider or taller.
  ///
  /// - Parameters:
  ///   - horizontalDayMargin: The amount of space between two day frames along the horizontal axis.
  /// - Returns: A mutated `CalendarViewContent` instance with a new horizontal day margin value.
  public func horizontalDayMargin(_ horizontalDayMargin: CGFloat) -> CalendarViewContent {
    self.horizontalDayMargin = horizontalDayMargin
    return self
  }

  /// Configures the days-of-the-week row's separator options. The separator appears below the days-of-the-week row.
  ///
  /// - Parameters:
  ///   - options: An instance that has properties to control various aspects of the separator's design.
  /// - Returns: A mutated `CalendarViewContent` instance with a days-of-the-week row separator configured.
  public func daysOfTheWeekRowSeparator(
    options: DaysOfTheWeekRowSeparatorOptions?)
    -> CalendarViewContent
  {
    daysOfTheWeekRowSeparatorOptions = options
    return self
  }

  /// Configures the month header item provider.
  ///
  /// `CalendarView` invokes the provided `monthHeaderItemProvider` for each month in the range of months being
  /// displayed. The `CalendarItemModel`s that you return will be used to create the views for each month header in
  /// `CalendarView`.
  ///
  /// If you don't configure your own month header item provider via this function, then a default month header item provider will be
  /// used.
  ///
  /// - Parameters:
  ///   - monthHeaderItemProvider: A closure (that is retained) that returns a `CalendarItemModel` representing a
  ///   month header.
  ///   - month: The `Month` for which to provide a month header item.
  /// - Returns: A mutated `CalendarViewContent` instance with a new month header item provider.
  public func monthHeaderItemProvider(
    _ monthHeaderItemProvider: @escaping (_ month: Month) -> AnyCalendarItemModel)
    -> CalendarViewContent
  {
    self.monthHeaderItemProvider = monthHeaderItemProvider
    return self
  }

  /// Configures the day-of-week item provider.
  ///
  /// `CalendarView` invokes the provided `dayOfWeekItemProvider` for each weekday index for the current calendar.
  /// For example, for the en_US locale, 0 is Sunday, 1 is Monday, and 6 is Saturday. This will be different in some other locales. The
  /// `CalendarItemModel`s that you return will be used to create the views for each day-of-week view in `CalendarView`.
  ///
  /// If you don't configure your own day-of-week item provider via this function, then a default day-of-week item provider will be used.
  ///
  /// - Parameters:
  ///   - dayOfWeekItemProvider: A closure (that is retained) that returns a `CalendarItemModel` representing a
  ///   day of the week.
  ///   - month: The month in which the day-of-week item belongs. This parameter will be `nil` if days of the week are pinned to
  ///   the top of the calendar, since in that scenario, they don't belong to any particular month.
  ///   - weekdayIndex: The weekday index for which to provide a `CalendarItemModel`.
  /// - Returns: A mutated `CalendarViewContent` instance with a new day-of-week item provider.
  public func dayOfWeekItemProvider(
    _ dayOfWeekItemProvider: @escaping (
      _ month: Month?,
      _ weekdayIndex: Int)
      -> AnyCalendarItemModel)
    -> CalendarViewContent
  {
    self.dayOfWeekItemProvider = dayOfWeekItemProvider
    return self
  }

  /// Configures the day item provider.
  ///
  /// `CalendarView` invokes the provided `dayItemProvider` for each day being displayed. The
  /// `CalendarItemModel`s that you return will be used to create the views for each day in `CalendarView`. In most cases, this
  /// view should be some kind of label that tells the user the day number of the month. You can also add other decoration, like a badge
  /// or background, by including it in the view that your `CalendarItemModel` creates.
  ///
  /// If you don't configure your own day item provider via this function, then a default day item provider will be used.
  ///
  /// - Parameters:
  ///   - dayItemProvider: A closure (that is retained) that returns a `CalendarItemModel` representing a single day
  ///   in the calendar.
  ///   - day: The `Day` for which to provide a day item.
  /// - Returns: A mutated `CalendarViewContent` instance with a new day item provider.
  public func dayItemProvider(
    _ dayItemProvider: @escaping (_ day: Day) -> AnyCalendarItemModel)
    -> CalendarViewContent
  {
    self.dayItemProvider = dayItemProvider
    return self
  }

  /// Configures the day background item provider.
  ///
  /// `CalendarView` invokes the provided `dayBackgroundItemProvider` for each day being displayed. The
  /// `CalendarItemModel`s that you return will be used to create the background views for each day in `CalendarView`. If a
  /// particular day does not have a background view, return `nil` for that day.
  ///
  /// If you don't configure a day background item provider via this function, then days will not have additional background decoration.
  ///
  /// - Parameters:
  ///   - dayBackgroundItemProvider: A closure (that is retained) that returns a `CalendarItemModel` representing the
  ///   background of a single day in the calendar.
  ///   - day: The `Day` for which to provide a day background item.
  /// - Returns: A mutated `CalendarViewContent` instance with a new day background item provider.
  public func dayBackgroundItemProvider(
    _ dayBackgroundItemProvider: @escaping (_ day: Day) -> AnyCalendarItemModel?)
    -> CalendarViewContent
  {
    self.dayBackgroundItemProvider = dayBackgroundItemProvider
    return self
  }

  /// Configures the month background item provider.
  ///
  /// `CalendarView` invokes the provided `monthBackgroundItemProvider` for each month being displayed. The
  /// `CalendarItemModel` that you return for each month will be used to create a view that spans the entire frame of that month,
  /// encapsulating all days, days-of-the-week headers, and the month header. This behavior makes month backgrounds useful for
  /// things like grid lines or colored backgrounds.
  ///
  /// If you don't configure your own month background item provider via this function, then months will not have additional
  /// background decoration.
  ///
  /// - Parameters:
  ///   - monthBackgroundItemProvider: A closure (that is retained) that returns a `CalendarItemModel` representing the
  ///   background of a single month in the calendar.
  ///   - monthLayoutContext: The layout context for the month containing information about the frames of views in that month
  ///   and the bounds in which your month background will be displayed.
  /// - Returns: A mutated `CalendarViewContent` instance with a new month background item provider.
  public func monthBackgroundItemProvider(
    _ monthBackgroundItemProvider: @escaping (
      _ monthLayoutContext: MonthLayoutContext)
      -> AnyCalendarItemModel?)
    -> CalendarViewContent
  {
    self.monthBackgroundItemProvider = monthBackgroundItemProvider
    return self
  }

  /// Configures the day range item provider.
  ///
  /// `CalendarView` invokes the provided `dayRangeItemProvider` for each day range in the `dateRanges` set.
  /// Date ranges will be converted to day ranges by using the `calendar`passed into the `CalendarViewContent` initializer. The
  /// `CalendarItemModel` that you return for each day range will be used to create a view that spans the entire frame
  /// encapsulating all days in that day range. This behavior makes day range items useful for things like day range selection indicators
  /// that might have specific styling requirements for different parts of the selected day range. For example, you might have a cross
  /// fade in your day range selection indicator view when a day range spans multiple months, or you might have rounded end caps for
  /// the start and end of a day range.
  ///
  /// The views created by the `CalendarItemModel`s provided by this function will be placed at a lower z-index than the layer of
  /// day items. If you don't configure your own day range item provider via this function, then no day range view will be displayed.
  ///
  /// If you don't want to show any day range items, pass in an empty set for the `dateRanges` parameter.
  ///
  /// - Parameters:
  ///   - dateRanges: The date ranges for which `CalendarView` will invoke your day range item provider closure.
  ///   - dayRangeItemProvider: A closure (that is retained) that returns a `CalendarItemModel` representing a day
  ///   range in the calendar.
  ///   - dayRangeLayoutContext: The layout context for the day range containing information about the frames of days and
  ///   bounds in which your day range item will be displayed.
  /// - Returns: A mutated `CalendarViewContent` instance with a new day range item provider.
  public func dayRangeItemProvider(
    for dateRanges: Set<ClosedRange<Date>>,
    _ dayRangeItemProvider: @escaping (
      _ dayRangeLayoutContext: DayRangeLayoutContext)
      -> AnyCalendarItemModel)
    -> CalendarViewContent
  {
    let dayRanges = Set(dateRanges.map { DayRange(containing: $0, in: calendar) })
    dayRangesAndItemProvider = (dayRanges, dayRangeItemProvider)
    return self
  }

  /// Configures the overlay item provider.
  ///
  /// `CalendarView` invokes the provided `overlayItemProvider` for each overlaid item location in the
  /// `overlaidItemLocations` set. All of the layout information needed to create an overlay item is provided via the overlay
  /// context passed into the `overlayItemProvider` closure. The `CalendarItemModel` that you return for each
  /// overlaid item location will be used to create a view that spans the visible bounds of the calendar when that overlaid item's location
  /// is visible. This behavior makes overlay items useful for things like tooltips.
  ///
  /// - Parameters:
  ///   - overlaidItemLocations: The overlaid item locations for which `CalendarView` will invoke your overlay item
  ///   provider closure.
  ///   - overlayItemProvider: A closure (that is retained) that returns a `CalendarItemModel` representing an
  ///   overlay.
  ///   - overlayLayoutContext: The layout context for the overlaid item location containing information about that location's
  ///   frame and the bounds in which your overlay item will be displayed.
  /// - Returns: A mutated `CalendarViewContent` instance with a new overlay item provider.
  public func overlayItemProvider(
    for overlaidItemLocations: Set<OverlaidItemLocation>,
    _ overlayItemProvider: @escaping (
      _ overlayLayoutContext: OverlayLayoutContext)
      -> AnyCalendarItemModel)
    -> CalendarViewContent
  {
    overlaidItemLocationsAndItemProvider = (overlaidItemLocations, overlayItemProvider)
    return self
  }

  // MARK: Internal

  let calendar: Calendar
  let dayRange: DayRange
  let monthRange: MonthRange
  let monthsLayout: MonthsLayout

  private(set) var dayAspectRatio: CGFloat = 1
  private(set) var dayOfWeekAspectRatio: CGFloat = 1
  private(set) var interMonthSpacing: CGFloat = 0
  private(set) var monthDayInsets: NSDirectionalEdgeInsets = .zero
  private(set) var verticalDayMargin: CGFloat = 0
  private(set) var horizontalDayMargin: CGFloat = 0
  private(set) var daysOfTheWeekRowSeparatorOptions: DaysOfTheWeekRowSeparatorOptions?

  private(set) var monthHeaderItemProvider: (Month) -> AnyCalendarItemModel
  private(set) var dayOfWeekItemProvider: (
    _ month: Month?,
    _ weekdayIndex: Int)
    -> AnyCalendarItemModel
  private(set) var dayItemProvider: (Day) -> AnyCalendarItemModel
  private(set) var dayBackgroundItemProvider: ((Day) -> AnyCalendarItemModel?)?
  private(set) var monthBackgroundItemProvider: ((MonthLayoutContext) -> AnyCalendarItemModel?)?
  private(set) var dayRangesAndItemProvider: (
    dayRanges: Set<DayRange>,
    dayRangeItemProvider: (DayRangeLayoutContext) -> AnyCalendarItemModel)?
  private(set) var overlaidItemLocationsAndItemProvider: (
    overlaidItemLocations: Set<OverlaidItemLocation>,
    overlayItemProvider: (OverlayLayoutContext) -> AnyCalendarItemModel)?

}
