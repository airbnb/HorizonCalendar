// Created by Bryan Keller on 2/1/23.
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

import SwiftUI
import UIKit

// MARK: - CalendarViewRepresentable

/// A declarative, performant calendar `View` that supports use cases ranging from simple date pickers all the way up to
/// fully-featured calendar apps. Its declarative API makes updating the calendar straightforward, while also providing many
/// customization points to support a diverse set of designs and use cases.
///
/// `CalendarView` does not handle any business logic related to day range selection or deselection. Instead, it provides a
/// single callback for day selection, allowing you to customize selection behavior in any way that you’d like.
///
/// Your business logic can respond to the day selection callback: update any backing-models for your feature. If those backing models
/// are inputs to your view (for example, `@State`), then the calendar will re-render with the latest data.
///
/// - Note: This `View` wraps a UIKit `CalendarView`, enabling it to be used in a SwiftUI hierarchy.
@available(iOS 13.0, *)
public struct CalendarViewRepresentable: UIViewRepresentable {

  // MARK: Lifecycle

  /// Initializes a `CalendarViewRepresentable` with default `CalendarItemModel` providers.
  ///
  /// - Parameters:
  ///   - calendar: The calendar on which all date operations will be performed. Defaults to `Calendar.current` (the system's
  ///   current calendar).
  ///   - visibleDateRange: The date range that will be displayed. The dates in this range are interpreted using the provided
  ///   `calendar`.
  ///   - monthsLayout: The layout of months - either vertically or horizontally.
  ///   - dataDependency: Any data or state that, when updated, should cause the calendar to re-render. This is needed because
  ///   `CalendarView` lazily invokes item provider closures outside of the normal SwiftUI update loop. To ensure that the calendar
  ///   is updated at the right times, pass in any properties that are accessed in your item provider closures. For example, if a
  ///   `dayItemProvider` closure accesses a local state variable called `selectedDay`, then pass it in here.
  public init(
    calendar: Calendar = Calendar.current,
    visibleDateRange: ClosedRange<Date>,
    monthsLayout: MonthsLayout,
    dataDependency: Any? = nil)
  {
    self.calendar = calendar
    self.visibleDateRange = visibleDateRange
    self.monthsLayout = monthsLayout
    self.dataDependency = dataDependency
  }

  // MARK: Public

  public func makeUIView(context: Context) -> CalendarView {
    CalendarView(initialContent: makeContent())
  }

  public func updateUIView(_ calendarView: CalendarView, context: Context) {
    calendarView.daySelectionHandler = daySelectionHandler
    calendarView.didScroll = didScroll
    calendarView.didEndDragging = didEndDragging
    calendarView.didEndDecelerating = didEndDecelerating

    calendarView.setContent(makeContent())
  }

  // MARK: Fileprivate

  fileprivate var dayAspectRatio: CGFloat?
  fileprivate var interMonthSpacing: CGFloat?
  fileprivate var monthDayInsets: NSDirectionalEdgeInsets?
  fileprivate var verticalDayMargin: CGFloat?
  fileprivate var horizontalDayMargin: CGFloat?
  fileprivate var daysOfTheWeekRowSeparatorOptions: DaysOfTheWeekRowSeparatorOptions?

  fileprivate var monthHeaderItemProvider: ((Month) -> AnyCalendarItemModel)?
  fileprivate var dayOfWeekItemProvider: ((
    _ month: Month?,
    _ weekdayIndex: Int)
    -> AnyCalendarItemModel)?
  fileprivate var dayItemProvider: ((Day) -> AnyCalendarItemModel)?
  fileprivate var dayBackgroundItemProvider: ((Day) -> AnyCalendarItemModel?)?
  fileprivate var monthBackgroundItemProvider: ((MonthLayoutContext) -> AnyCalendarItemModel?)?
  fileprivate var dateRangesAndItemProvider: (
    dayRanges: Set<ClosedRange<Date>>,
    dayRangeItemProvider: (DayRangeLayoutContext) -> AnyCalendarItemModel)?
  fileprivate var overlaidItemLocationsAndItemProvider: (
    overlaidItemLocations: Set<OverlaidItemLocation>,
    overlayItemProvider: (OverlayLayoutContext) -> AnyCalendarItemModel)?

  fileprivate var daySelectionHandler: ((Day) -> Void)?
  fileprivate var didScroll: ((_ visibleDayRange: DayRange, _ isUserDragging: Bool) -> Void)?
  fileprivate var didEndDragging: ((_ visibleDayRange: DayRange, _ willDecelerate: Bool) -> Void)?
  fileprivate var didEndDecelerating: ((_ visibleDayRange: DayRange) -> Void)?

  // MARK: Private

  private let calendar: Calendar
  private let visibleDateRange: ClosedRange<Date>
  private let monthsLayout: MonthsLayout
  private let dataDependency: Any?

  private func makeContent() -> CalendarViewContent {
    var content = CalendarViewContent(
      calendar: calendar,
      visibleDateRange: visibleDateRange,
      monthsLayout: monthsLayout)

    if let dayAspectRatio {
      content = content.dayAspectRatio(dayAspectRatio)
    }

    if let interMonthSpacing {
      content = content.interMonthSpacing(interMonthSpacing)
    }

    if let monthDayInsets {
      content = content.monthDayInsets(monthDayInsets)
    }

    if let verticalDayMargin {
      content = content.verticalDayMargin(verticalDayMargin)
    }

    if let horizontalDayMargin {
      content = content.horizontalDayMargin(horizontalDayMargin)
    }

    content = content.daysOfTheWeekRowSeparator(options: daysOfTheWeekRowSeparatorOptions)

    if let monthHeaderItemProvider {
      content = content.monthHeaderItemProvider(monthHeaderItemProvider)
    }

    if let dayOfWeekItemProvider {
      content = content.dayOfWeekItemProvider(dayOfWeekItemProvider)
    }

    if let dayItemProvider {
      content = content.dayItemProvider(dayItemProvider)
    }

    if let dayBackgroundItemProvider {
      content = content.dayBackgroundItemProvider(dayBackgroundItemProvider)
    }

    if let monthBackgroundItemProvider {
      content = content.monthBackgroundItemProvider(monthBackgroundItemProvider)
    }

    if let (dateRanges, itemProvider) = dateRangesAndItemProvider {
      content = content.dayRangeItemProvider(for: dateRanges, itemProvider)
    }

    if let (itemLocations, itemProvider) = overlaidItemLocationsAndItemProvider {
      content = content.overlayItemProvider(for: itemLocations, itemProvider)
    }

    return content
  }

}

// MARK: Content Modifiers

@available(iOS 13.0, *)
extension CalendarViewRepresentable {

  public func dayAspectRatio(_ dayAspectRatio: CGFloat) -> Self {
    var view = self
    view.dayAspectRatio = dayAspectRatio
    return view
  }

  public func interMonthSpacing(_ interMonthSpacing: CGFloat) -> Self {
    var view = self
    view.interMonthSpacing = interMonthSpacing
    return view
  }

  public func monthDayInsets(_ monthDayInsets: NSDirectionalEdgeInsets) -> Self {
    var view = self
    view.monthDayInsets = monthDayInsets
    return view
  }

  public func verticalDayMargin(_ verticalDayMargin: CGFloat) -> Self {
    var view = self
    view.verticalDayMargin = verticalDayMargin
    return view
  }

  public func horizontalDayMargin(_ horizontalDayMargin: CGFloat) -> Self {
    var view = self
    view.horizontalDayMargin = horizontalDayMargin
    return view
  }

  public func daysOfTheWeekRowSeparator(
    options daysOfTheWeekRowSeparatorOptions: DaysOfTheWeekRowSeparatorOptions?)
    -> Self
  {
    var view = self
    view.daysOfTheWeekRowSeparatorOptions = daysOfTheWeekRowSeparatorOptions
    return view
  }

  public func monthHeaderItemProvider(
    _ monthHeaderItemProvider: @escaping (_ month: Month) -> AnyCalendarItemModel)
    -> Self
  {
    var view = self
    view.monthHeaderItemProvider = monthHeaderItemProvider
    return view
  }

  public func dayOfWeekItemProvider(
    _ dayOfWeekItemProvider: @escaping (
      _ month: Month?,
      _ weekdayIndex: Int)
      -> AnyCalendarItemModel)
    -> Self
  {
    var view = self
    view.dayOfWeekItemProvider = dayOfWeekItemProvider
    return view
  }

  public func dayItemProvider(
    _ dayItemProvider: @escaping (_ day: Day) -> AnyCalendarItemModel)
    -> Self
  {
    var view = self
    view.dayItemProvider = dayItemProvider
    return view
  }

  public func dayBackgroundItemProvider(
    _ dayBackgroundItemProvider: @escaping (_ day: Day) -> AnyCalendarItemModel?)
    -> Self
  {
    var view = self
    view.dayBackgroundItemProvider = dayBackgroundItemProvider
    return view
  }

  public func monthBackgroundItemProvider(
    _ monthBackgroundItemProvider: @escaping (
      _ monthLayoutContext: MonthLayoutContext)
      -> AnyCalendarItemModel?)
    -> Self
  {
    var view = self
    view.monthBackgroundItemProvider = monthBackgroundItemProvider
    return view
  }

  public func dayRangeItemProvider(
    for dateRanges: Set<ClosedRange<Date>>,
    _ dayRangeItemProvider: @escaping (
      _ dayRangeLayoutContext: DayRangeLayoutContext)
    -> AnyCalendarItemModel)
    -> Self
  {
    var view = self
    view.dateRangesAndItemProvider = (dateRanges, dayRangeItemProvider)
    return view
  }

  public func overlayItemProvider(
    for overlaidItemLocations: Set<OverlaidItemLocation>,
    _ overlayItemProvider: @escaping (
      _ overlayLayoutContext: OverlayLayoutContext)
    -> AnyCalendarItemModel)
    -> Self
  {
    var view = self
    view.overlaidItemLocationsAndItemProvider = (overlaidItemLocations, overlayItemProvider)
    return view
  }

}

// MARK: Event Handlers

@available(iOS 13.0, *)
extension CalendarViewRepresentable {

  public func onDaySelection(_ daySelectionHandler: @escaping (Day) -> Void) -> Self {
    var view = self
    view.daySelectionHandler = daySelectionHandler
    return view
  }

  public func onScroll(
    _ scrollHandler: @escaping (_ visibleDayRange: DayRange,  _ isUserDragging: Bool) -> Void)
    -> Self
  {
    var view = self
    view.didScroll = scrollHandler
    return view
  }

  public func onDragEnd(
    _ dragEndHandler: @escaping (_ visibleDayRange: DayRange, _ willDecelerate: Bool) -> Void)
    -> Self
  {
    var view = self
    view.didEndDragging = dragEndHandler
    return view
  }

  public func onDeceleratingEnd(
    _ deceleratingEndHandler: @escaping (_ visibleDayRange: DayRange) -> Void)
    -> Self
  {
    var view = self
    view.didEndDecelerating = deceleratingEndHandler
    return view
  }

}
