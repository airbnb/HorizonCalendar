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

  /// Initializes a new `CalendarViewContent` with default `CalendarItem` providers.
  ///
  /// - Parameters:
  ///   - calendar: The calendar on which all date operations will be performed. Defaults to `Calendar.current` (the system's
  ///   current calendar).
  ///   - visibleDateRange: The date range that will be displayed. The dates in this range are interpretted using the provided
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
    monthHeaderDateFormatter.dateFormat = DateFormatter.dateFormat(
      fromTemplate: "MMMM yyyy",
      options: 0,
      locale: calendar.locale ?? Locale.current)

    monthHeaderItemProvider = { month in
      CalendarViewContent.defaultMonthHeaderItemProvider(
        for: month,
        calendar: calendar,
        dateFormatter: monthHeaderDateFormatter)
    }

    dayOfWeekItemProvider = { _, weekdayIndex in
      CalendarViewContent.defaultDayOfWeekItemProvider(
        forWeekdayIndex: weekdayIndex,
        calendar: calendar,
        dateFormatter: monthHeaderDateFormatter)
    }

    let dayDateFormatter = DateFormatter()
    dayDateFormatter.calendar = calendar
    dayDateFormatter.dateFormat = DateFormatter.dateFormat(
      fromTemplate: "EEEE, MMM d, yyyy",
      options: 0,
      locale: calendar.locale ?? Locale.current)

    dayItemProvider = { day in
      CalendarViewContent.defaultDayItemProvider(
        for: day,
        calendar: calendar,
        dateFormatter: dayDateFormatter)
    }
  }

  // MARK: Public

  /// Configures the background color of `CalendarView`. The default value is `.systemBackground` on iOS 13+, and
  /// `.white` on earlier iOS versions.
  ///
  /// - Parameters:
  ///   - backgroundColor: The backround color of the calendar.
  /// - Returns: A mutated `CalendarViewContent` instance with a new background color.
  public func withBackgroundColor(_ backgroundColor: UIColor) -> CalendarViewContent {
    self.backgroundColor = backgroundColor
    return self
  }

  /// Configures the amount of spacing, in points, between months. The default value is `0`.
  ///
  /// - Parameters:
  ///   - interMonthSpacing: The amount of spacing, in points, between months.
  /// - Returns: A mutated `CalendarViewContent` instance with a new inter-month-spacing value.
  public func withInterMonthSpacing(_ interMonthSpacing: CGFloat) -> CalendarViewContent {
    self.interMonthSpacing = interMonthSpacing
    return self
  }

  /// Configures the amount to inset days and day-of-week items from the edges of a month. The default value is `.zero`.
  ///
  /// - Parameters:
  ///   - monthDayInsets: The amount to inset days and day-of-week items from the edges of a month.
  /// - Returns: A mutated `CalendarViewContent` instance with a new month-day-insets value.
  public func withMonthDayInsets(_ monthDayInsets: UIEdgeInsets) -> CalendarViewContent {
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
  public func withVerticalDayMargin(_ verticalDayMargin: CGFloat) -> CalendarViewContent {
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
  public func withHorizontalDayMargin(_ horizontalDayMargin: CGFloat) -> CalendarViewContent {
    self.horizontalDayMargin = horizontalDayMargin
    return self
  }

  /// Configures the days-of-the-week row's separator options. The separator appears below the days-of-the-week row.
  ///
  /// - Parameters:
  ///   - options: An instance that has properties to control various aspects of the separator's design.
  /// - Returns: A mutated `CalendarViewContent` instance with a days-of-the-week row separator configured.
  public func withDaysOfTheWeekRowSeparator(
    options: DaysOfTheWeekRowSeparatorOptions)
    -> CalendarViewContent
  {
    daysOfTheWeekRowSeparatorOptions = options
    return self
  }

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
  public func withMonthHeaderItemProvider(
    _ monthHeaderItemProvider: @escaping (_ month: Month) -> AnyCalendarItem)
    -> CalendarViewContent
  {
    self.monthHeaderItemProvider = monthHeaderItemProvider
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
  public func withDayOfWeekItemProvider(
    _ dayOfWeekItemProvider: @escaping (_ month: Month?, _ weekdayIndex: Int) -> AnyCalendarItem)
    -> CalendarViewContent
  {
    self.dayOfWeekItemProvider = dayOfWeekItemProvider
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
  public func withDayItemProvider(
    _ dayItemProvider: @escaping (_ day: Day) -> AnyCalendarItem)
    -> CalendarViewContent
  {
    self.dayItemProvider = dayItemProvider
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
  public func withDayRangeItemProvider(
    for dateRanges: Set<ClosedRange<Date>>,
    _ dayRangeItemProvider: @escaping (
      _ dayRangeLayoutContext: DayRangeLayoutContext)
      -> AnyCalendarItem)
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
  public func withOverlayItemProvider(
    for overlaidItemLocations: Set<OverlaidItemLocation>,
    _ overlayItemProvider: @escaping (
      _ overlayLayoutContext: OverlayLayoutContext)
      -> AnyCalendarItem)
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

  private(set) var backgroundColor: UIColor = {
    if #available(iOS 13.0, *) {
      return UIColor.systemBackground
    } else {
      return UIColor.white
    }
  }()
  private(set) var interMonthSpacing: CGFloat = 0
  private(set) var monthDayInsets: UIEdgeInsets = .zero
  private(set) var verticalDayMargin: CGFloat = 0
  private(set) var horizontalDayMargin: CGFloat = 0
  private(set) var daysOfTheWeekRowSeparatorOptions: DaysOfTheWeekRowSeparatorOptions?

  private(set) var monthHeaderItemProvider: (Month) -> AnyCalendarItem
  private(set) var dayOfWeekItemProvider: (_ month: Month?, _ weekdayIndex: Int) -> AnyCalendarItem
  private(set) var dayItemProvider: (Day) -> AnyCalendarItem
  private(set) var dayRangesAndItemProvider: (
    dayRanges: Set<DayRange>,
    dayRangeItemProvider: (DayRangeLayoutContext) -> AnyCalendarItem)?
  private(set) var overlaidItemLocationsAndItemProvider: (
    overlaidItemLocations: Set<OverlaidItemLocation>,
    overlayItemProvider: (OverlayLayoutContext) -> AnyCalendarItem)?

}

// MARK: - CalendarViewContent.DayRangeLayoutContext

extension CalendarViewContent {

  /// The layout context for a day range, containing information about the frames of days in the day range and the bounding rect (union)
  /// of those days frames.
  public struct DayRangeLayoutContext {
    /// An ordered list of tuples containing day and day frame pairs.
    ///
    /// Each day frame represents the frame of an individual day in the day range in the coordinate system of
    /// `boundingUnionRectOfDayFrames`.
    public let daysAndFrames: [(day: Day, frame: CGRect)]

    /// A rectangle that perfectly contains all day frames in `daysAndFrames`. In other words, it is the union of all day frames in
    /// `daysAndFrames`.
    public let boundingUnionRectOfDayFrames: CGRect
  }

}

// MARK: - CalendarViewContent.OverlaidItemLocation

extension CalendarViewContent {

  /// Represents the location of an item that can be overlaid.
  public enum OverlaidItemLocation: Hashable {

    /// A month header location that can be overlaid.
    ///
    /// The particular month to be overlaid is specified with a `Date` instance, which will be used to determine the associated month
    /// using the `calendar` instance with which `CalendarViewContent` was instantiated.
    case monthHeader(monthContainingDate: Date)

    /// A day location that can be overlaid.
    ///
    /// The particular day to be overlaid is specified with a `Date` instance, which will be used to determine the associated day
    /// using the `calendar` instance with which `CalendarViewContent` was instantiated.
    case day(containingDate: Date)
  }

}


// MARK: - CalendarViewContent.OverlayLayoutContext

extension CalendarViewContent {

  /// The layout context for an overlaid item, containing information about the location and frame of the item being overlaid, as well as
  /// the bounds available to the overlay item for drawing and layout.
  public struct OverlayLayoutContext {

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

  }

}

// MARK: - CalendarViewContent.DaysOfTheWeekRowSeparatorOptions

extension CalendarViewContent {

  /// Used to configure the days-of-the-week row's separator.
  public struct DaysOfTheWeekRowSeparatorOptions {

    // MARK: Lifecycle

    /// Initialized a new `DaysOfTheWeekRowSeparatorOptions`.
    ///
    /// - Parameters:
    ///   - height: The height of the separator in points.
    ///   - color: The color of the separator.
    public init(height: CGFloat = 1, color: UIColor = .lightGray) {
      self.height = height
      self.color = color
    }

    // MARK: Public

    @available(iOS 13.0, *)
    public static var systemStyleSeparator = DaysOfTheWeekRowSeparatorOptions(
      height: 1,
      color: .separator)

    /// The height of the separator in points.
    public var height: CGFloat

    /// The color of the separator.
    public var color: UIColor
  }

}

// MARK: Defaults

extension CalendarViewContent {

  // MARK: Internal

  private static func defaultMonthHeaderItemProvider(
    for month: Month,
    calendar: Calendar,
    dateFormatter: DateFormatter)
    -> AnyCalendarItem
  {
    return CalendarItem<UILabel, String>(
      viewModel: dateFormatter.string(from: calendar.firstDate(of: month)),
      styleID: "DefaultMonthHeaderItem",
      buildView: {
        let label = UILabel()
        label.textAlignment = .natural
        label.font = UIFont.systemFont(ofSize: 22)
        if #available(iOS 13.0, *) {
          label.textColor = .label
        } else {
          label.textColor = .black
        }
        label.isAccessibilityElement = true
        label.accessibilityTraits = [.header]
        return label
      },
      updateViewModel: { label, monthText in
        label.text = monthText
        label.accessibilityLabel = monthText
      })
  }

  private static func defaultDayOfWeekItemProvider(
    forWeekdayIndex weekdayIndex: Int,
    calendar: Calendar,
    dateFormatter: DateFormatter)
    -> AnyCalendarItem
  {
    CalendarItem<UILabel, String>(
      viewModel: dateFormatter.veryShortStandaloneWeekdaySymbols[weekdayIndex],
      styleID: "DefaultDayOfWeekItem",
      buildView: {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        if #available(iOS 13.0, *) {
          label.textColor = .secondaryLabel
          label.backgroundColor = .systemBackground
        } else {
          label.textColor = .black
          label.backgroundColor = .white
        }
        label.isAccessibilityElement = false
        return label
      },
      updateViewModel: { label, dayOfWeekText in
        label.text = dayOfWeekText
      })
  }

  private static func defaultDayItemProvider(
    for day: Day,
    calendar: Calendar,
    dateFormatter: DateFormatter)
    -> AnyCalendarItem
  {
    CalendarItem<UILabel, Day>(
      viewModel: day,
      styleID: "DefaultDayItem",
      buildView: {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        if #available(iOS 13.0, *) {
          label.textColor = .label
        } else {
          label.textColor = .black
        }
        label.isAccessibilityElement = true
        return label
      },
      updateViewModel: { label, day in
        label.text = "\(day.day)"

        let date = calendar.startDate(of: day)
        label.accessibilityLabel = dateFormatter.string(from: date)
      })
  }

}
