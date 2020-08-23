// Created by Bryan Keller on 8/22/20.
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

extension CalendarViewContent {

  /// Configures the month header item provider.
  ///
  /// `CalendarView` invokes the provided `monthHeaderItemProvider` for each month in the range of months being
  /// displayed. The `CalendarItem`s that you return will be used to create the views for each month header in `CalendarView`.
  ///
  /// If you don't configure your own month header item provider via this function, then a default month header item provider will be
  /// used.
  ///
  /// - Parameters:
  ///   - monthHeaderItemProvider: A closure (that is retained) that returns a `CalendarItem` representing a month header.
  ///   - month: The `Month` for which to provide a month header item.
  /// - Returns: A mutated `CalendarViewContent` instance with a new month header item provider.
  @available(
    *,
    deprecated,
    message: "`CalendarItem` has been replaced with `CalendarItemModel`, a type that simplifies the creation of views displayed in `CalendarView`. Use `withMonthHeaderItemModelProvider` instead.")
  public func withMonthHeaderItemProvider(
    _ monthHeaderItemProvider: @escaping (_ month: Month) -> AnyCalendarItem)
    -> CalendarViewContent
  {
    monthHeaderItemModelProvider = { .legacy(monthHeaderItemProvider($0)) }
    return self
  }

  /// Configures the day-of-week item provider.
  ///
  /// `CalendarView` invokes the provided `dayOfWeekItemProvider` for each weekday index for the current calendar. For
  /// example, for the en_US locale, 0 is Sunday, 1 is Monday, and 6 is Saturday. This will be different in some other locales. The
  /// `CalendarItem`s that you return will be used to create the views for each day-of-week view in `CalendarView`.
  ///
  /// If you don't configure your own day-of-week item provider via this function, then a default day-of-week item provider will be used.
  ///
  /// - Parameters:
  ///   - dayOfWeekItemProvider: A closure (that is retained) that returns a `CalendarItem` representing a day of the week.
  ///   - month: The month in which the day-of-week item belongs. This parameter will be `nil` if days of the week are pinned to
  ///   the top of the calendar, since in that scenario, they don't belong to any particular month.
  ///   - weekdayIndex: The weekday index for which to provide a `CalendarItem`.
  /// - Returns: A mutated `CalendarViewContent` instance with a new day-of-week item provider.
  @available(
    *,
    deprecated,
    message: "`CalendarItem` has been replaced with `CalendarItemModel`, a type that simplifies the creation of views displayed in `CalendarView`. Use `withDayOfWeekItemModelProvider` instead.")
  public func withDayOfWeekItemProvider(
    _ dayOfWeekItemProvider: @escaping (_ month: Month?, _ weekdayIndex: Int) -> AnyCalendarItem)
    -> CalendarViewContent
  {
    dayOfWeekItemModelProvider = { .legacy(dayOfWeekItemProvider($0, $1)) }
    return self
  }

  /// Configures the day item provider.
  ///
  /// `CalendarView` invokes the provided `dayItemProvider` for each day being displayed. The `CalendarItem`s that you
  /// return will be used to create the views for each day in `CalendarView`. In most cases, this view should be some kind of label
  /// that tells the user the day number of the month. You can also add other decoration, like a badge or background, by including it in
  /// the view that your `CalendarItem` creates.
  ///
  /// If you don't configure your own day item provider via this function, then a default day item provider will be used.
  ///
  /// - Parameters:
  ///   - dayItemProvider: A closure (that is retained) that returns a `CalendarItem` representing a single day in the
  ///   calendar.
  ///   - day: The `Day` for which to provide a day item.
  /// - Returns: A mutated `CalendarViewContent` instance with a new day item provider.
  @available(
    *,
    deprecated,
    message: "`CalendarItem` has been replaced with `CalendarItemModel`, a type that simplifies the creation of views displayed in `CalendarView`. Use `withDayItemModelProvider` instead.")
  public func withDayItemProvider(
    _ dayItemProvider: @escaping (_ day: Day) -> AnyCalendarItem)
    -> CalendarViewContent
  {
    dayItemModelProvider = { .legacy(dayItemProvider($0)) }
    return self
  }

  /// Configures the day range item provider.
  ///
  /// `CalendarView` invokes the provided `dayRangeItemProvider` for each day range in the `dateRanges` set. Date
  /// ranges will be converted to day ranges by using the `calendar`passed into the `CalendarViewContent` initializer. The
  /// `CalendarItem` that you return for each day range will be used to create a view that spans the entire frame encapsulating all
  /// days in that day range. This behavior makes day range items useful for things like day range selection indicators that might have
  /// specific styling requirements for different parts of the selected day range. For example, you might have a cross fade in your day
  /// range selection indicator view when a day range spans multiple months, or you might have rounded end caps for the start and
  /// end of a day range.
  ///
  /// The views created by the `CalendarItem`s provided by this function will be placed at a lower z-index than the layer of day
  /// items. If you don't configure your own day range item provider via this function, then no day range view will be displayed.
  ///
  /// If you don't want to show any day range items, pass in an empty set for the `dateRanges` parameter.
  ///
  /// - Parameters:
  ///   - dateRanges: The date ranges for which `CalendarView` will invoke your day range item provider closure.
  ///   - dayRangeItemProvider: A closure (that is retained) that returns a `CalendarItem` representing a day range in the
  ///   calendar.
  ///   - dayRangeLayoutContext: The layout context for the day range containing information about the frames of days and
  ///   bounds in which your day range item will be displayed.
  /// - Returns: A mutated `CalendarViewContent` instance with a new day range item provider.
  @available(
    *,
    deprecated,
    message: "`CalendarItem` has been replaced with `CalendarItemModel`, a type that simplifies the creation of views displayed in `CalendarView`. Use `withDayRangeItemModelProvider` instead.")
  public func withDayRangeItemProvider(
    for dateRanges: Set<ClosedRange<Date>>,
    _ dayRangeItemProvider: @escaping (
      _ dayRangeLayoutContext: DayRangeLayoutContext)
      -> AnyCalendarItem)
    -> CalendarViewContent
  {
    let dayRanges = Set(dateRanges.map { DayRange(containing: $0, in: calendar) })
    dayRangesAndItemModelProvider = (dayRanges, { .legacy(dayRangeItemProvider($0)) })
    return self
  }

  /// Configures the overlay item provider.
  ///
  /// `CalendarView` invokes the provided `overlayItemProvider` for each overlaid item location in the
  /// `overlaidItemLocations` set. All of the layout information needed to create an overlay item is provided via the overlay
  /// context passed into the `overlayItemProvider` closure. The `CalendarItem` that you return for each overlaid item
  /// location will be used to create a view that spans the visible bounds of the calendar when that overlaid item's location is visible. This
  /// behavior makes overlay items useful for things like tooltips.
  ///
  /// - Parameters:
  ///   - overlaidItemLocations: The overlaid item locations for which `CalendarView` will invoke your overlay item
  ///   provider closure.
  ///   - overlayItemProvider: A closure (that is retained) that returns a `CalendarItem` representing an overlay.
  ///   - overlayLayoutContext: The layout context for the overlaid item location containing information about that location's
  ///   frame and the bounds in which your overlay item will be displayed.
  /// - Returns: A mutated `CalendarViewContent` instance with a new overlay item provider.
  @available(
    *,
    deprecated,
    message: "`CalendarItem` has been replaced with `CalendarItemModel`, a type that simplifies the creation of views displayed in `CalendarView`. Use `withOverlayItemModelProvider` instead.")
  public func withOverlayItemProvider(
    for overlaidItemLocations: Set<OverlaidItemLocation>,
    _ overlayItemProvider: @escaping (
      _ overlayLayoutContext: OverlayLayoutContext)
      -> AnyCalendarItem)
    -> CalendarViewContent
  {
    overlaidItemLocationsAndItemModelProvider = (
      overlaidItemLocations,
      { .legacy(overlayItemProvider($0)) })
    return self
  }
  
}
