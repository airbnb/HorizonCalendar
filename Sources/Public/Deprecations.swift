// Created by Bryan Keller on 12/22/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

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

// MARK: CalendarView Deprecations

extension CalendarView {

  @available(*, deprecated, renamed: "isOverScrolling")
  public var isOverscrolling: Bool {
    isOverScrolling
  }

}

// MARK: MonthsLayout Deprecations

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

// MARK: CalendarViewContent Deprecations

extension CalendarViewContent {

  /// Configures the aspect ratio of each day.
  ///
  /// Values less than 1 will result in rectangular days that are wider than they are tall. Values
  /// greater than 1 will result in rectangular days that are taller than they are wide. The default value is `1`, which results in square
  /// views with the same width and height.
  ///
  /// - Parameters:
  ///   - dayAspectRatio: The aspect ratio of each day view.
  /// - Returns: A mutated `CalendarViewContent` instance with a new day aspect ratio value.
  @available(
    *,
    deprecated,
    renamed: "dayAspectRatio(_:)")
  public func withDayAspectRatio(_ dayAspectRatio: CGFloat) -> CalendarViewContent {
    self.dayAspectRatio(dayAspectRatio)
  }

  /// Configures the amount of spacing, in points, between months. The default value is `0`.
  ///
  /// - Parameters:
  ///   - interMonthSpacing: The amount of spacing, in points, between months.
  /// - Returns: A mutated `CalendarViewContent` instance with a new inter-month-spacing value.
  @available(
    *,
    deprecated,
    renamed: "interMonthSpacing(_:)")
  public func withInterMonthSpacing(_ interMonthSpacing: CGFloat) -> CalendarViewContent {
    self.interMonthSpacing(interMonthSpacing)
  }

  /// Configures the amount to inset days and day-of-week items from the edges of a month. The default value is `.zero`.
  ///
  /// - Parameters:
  ///   - monthDayInsets: The amount to inset days and day-of-week items from the edges of a month.
  /// - Returns: A mutated `CalendarViewContent` instance with a new month-day-insets value.
  @available(
    *,
    deprecated,
    renamed: "monthDayInsets(_:)")
  public func withMonthDayInsets(_ monthDayInsets: UIEdgeInsets) -> CalendarViewContent {
    self.monthDayInsets(monthDayInsets)
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
  @available(
    *,
    deprecated,
    renamed: "verticalDayMargin(_:)")
  public func withVerticalDayMargin(_ verticalDayMargin: CGFloat) -> CalendarViewContent {
    self.verticalDayMargin(verticalDayMargin)
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
  @available(
    *,
    deprecated,
    renamed: "horizontalDayMargin(_:)")
  public func withHorizontalDayMargin(_ horizontalDayMargin: CGFloat) -> CalendarViewContent {
    self.horizontalDayMargin(horizontalDayMargin)
  }

  /// Configures the days-of-the-week row's separator options. The separator appears below the days-of-the-week row.
  ///
  /// - Parameters:
  ///   - options: An instance that has properties to control various aspects of the separator's design.
  /// - Returns: A mutated `CalendarViewContent` instance with a days-of-the-week row separator configured.
  @available(
    *,
    deprecated,
    renamed: "daysOfTheWeekRowSeparator(options:)")
  public func withDaysOfTheWeekRowSeparator(
    options: DaysOfTheWeekRowSeparatorOptions)
    -> CalendarViewContent
  {
    daysOfTheWeekRowSeparator(options: options)
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
  @available(
    *,
    deprecated,
    renamed: "monthHeaderItemProvider(_:)")
  public func withMonthHeaderItemProvider(
    _ monthHeaderItemProvider: @escaping (_ month: Month) -> AnyCalendarItemModel)
    -> CalendarViewContent
  {
    self.monthHeaderItemProvider(monthHeaderItemProvider)
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
  @available(
    *,
    deprecated,
    renamed: "dayOfWeekItemProvider(_:)")
  public func withDayOfWeekItemProvider(
    _ dayOfWeekItemProvider: @escaping (
      _ month: Month?,
      _ weekdayIndex: Int)
      -> AnyCalendarItemModel)
    -> CalendarViewContent
  {
    self.dayOfWeekItemProvider(dayOfWeekItemProvider)
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
  @available(
    *,
    deprecated,
    renamed: "dayItemProvider(_:)")
  public func withDayItemProvider(
    _ dayItemProvider: @escaping (_ day: Day) -> AnyCalendarItemModel)
    -> CalendarViewContent
  {
    self.dayItemProvider(dayItemProvider)
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
  @available(
    *,
    deprecated,
    renamed: "dayRangeItemProvider(for:_:)")
  public func withDayRangeItemProvider(
    for dateRanges: Set<ClosedRange<Date>>,
    _ dayRangeItemProvider: @escaping (
      _ dayRangeLayoutContext: DayRangeLayoutContext)
      -> AnyCalendarItemModel)
    -> CalendarViewContent
  {
    self.dayRangeItemProvider(for: dateRanges, dayRangeItemProvider)
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
  @available(
    *,
    deprecated,
    renamed: "overlayItemProvider(for:_:)")
  public func withOverlayItemProvider(
    for overlaidItemLocations: Set<OverlaidItemLocation>,
    _ overlayItemProvider: @escaping (
      _ overlayLayoutContext: OverlayLayoutContext)
      -> AnyCalendarItemModel)
    -> CalendarViewContent
  {
    self.overlayItemProvider(for: overlaidItemLocations, overlayItemProvider)
  }

}
