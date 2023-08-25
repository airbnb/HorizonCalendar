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
  ///   - proxy: A proxy instance that can be used to programmatically scroll the calendar.
  public init(
    calendar: Calendar = Calendar.current,
    visibleDateRange: ClosedRange<Date>,
    monthsLayout: MonthsLayout,
    dataDependency: Any?,
    proxy: CalendarViewProxy? = nil)
  {
    self.calendar = calendar
    self.visibleDateRange = visibleDateRange
    self.monthsLayout = monthsLayout
    self.dataDependency = dataDependency
    self.proxy = proxy
  }

  // MARK: Public

  public func makeUIView(context: Context) -> CalendarView {
    let calendarView = CalendarView(initialContent: makeContent())
    calendarView.directionalLayoutMargins = .zero
    proxy?._calendarView = calendarView
    return calendarView
  }

  public func updateUIView(_ calendarView: CalendarView, context: Context) {
    calendarView.backgroundColor = backgroundColor ?? calendarView.backgroundColor
    calendarView.directionalLayoutMargins = layoutMargins ?? calendarView.directionalLayoutMargins

    calendarView.daySelectionHandler = daySelectionHandler
    calendarView.multiDaySelectionDragHandler = multiDaySelectionDragHandler
    calendarView.didScroll = didScroll
    calendarView.didEndDragging = didEndDragging
    calendarView.didEndDecelerating = didEndDecelerating

    // There's no public API for inheriting the `context.transaction.animation`'s properties here so
    // that we can do an equivalent `UIView` animation.
    calendarView.setContent(makeContent(), animated: false)
  }

  // MARK: Fileprivate

  fileprivate var backgroundColor: UIColor?
  fileprivate var layoutMargins: NSDirectionalEdgeInsets?

  fileprivate var dayAspectRatio: CGFloat?
  fileprivate var dayOfWeekAspectRatio: CGFloat?
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
  fileprivate var multiDaySelectionDragHandler: ((Day, UIGestureRecognizer.State) -> Void)?
  fileprivate var didScroll: ((_ visibleDayRange: DayRange, _ isUserDragging: Bool) -> Void)?
  fileprivate var didEndDragging: ((_ visibleDayRange: DayRange, _ willDecelerate: Bool) -> Void)?
  fileprivate var didEndDecelerating: ((_ visibleDayRange: DayRange) -> Void)?

  // MARK: Private

  private let calendar: Calendar
  private let visibleDateRange: ClosedRange<Date>
  private let monthsLayout: MonthsLayout
  private let dataDependency: Any?
  private let proxy: CalendarViewProxy?

  private func makeContent() -> CalendarViewContent {
    var content = CalendarViewContent(
      calendar: calendar,
      visibleDateRange: visibleDateRange,
      monthsLayout: monthsLayout)

    if let dayAspectRatio {
      content = content.dayAspectRatio(dayAspectRatio)
    }

    if let dayOfWeekAspectRatio {
      content = content.dayOfWeekAspectRatio(dayOfWeekAspectRatio)
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

  /// Configures the background color of the calendar view.
  ///
  ///  - Parameters:
  ///     - backgroundColor: The background color to apply to the calendar view.
  ///  - Returns: A new `CalendarViewRepresentable` with a new background color.
  public func backgroundColor(_ backgroundColor: UIColor) -> Self {
    var view = self
    view.backgroundColor = backgroundColor
    return view
  }

  /// Configures the layout margins of the calendar view.
  ///
  ///  - Parameters:
  ///     - layoutMargins: The layout margins to apply to the calendar view.
  ///  - Returns: A new `CalendarViewRepresentable` with new layout margins.
  public func layoutMargins(_ layoutMargins: NSDirectionalEdgeInsets) -> Self {
    var view = self
    view.layoutMargins = layoutMargins
    return view
  }

  /// Configures the aspect ratio of each day.
  ///
  /// Values less than 1 will result in rectangular days that are wider than they are tall. Values greater than 1 will result in rectangular
  /// days that are taller than they are wide. The default value is `1`, which results in square views with the same width and height.
  ///
  /// - Parameters:
  ///   - dayAspectRatio: The aspect ratio of each day view.
  /// - Returns: A new `CalendarViewRepresentable` with a new day aspect ratio value.
  public func dayAspectRatio(_ dayAspectRatio: CGFloat) -> Self {
    var view = self
    view.dayAspectRatio = dayAspectRatio
    return view
  }

  /// Configures the aspect ratio of each day of the week.
  ///
  /// Values less than 1 will result in rectangular days of the week that are wider than they are tall. Values greater than 1 will result in
  /// rectangular days of the week that are taller than they are wide. The default value is `1`, which results in square views with the
  /// same width and height.
  ///
  /// - Parameters:
  ///   - dayAspectRatio: The aspect ratio of each day-of-the-week view.
  /// - Returns: A new `CalendarViewRepresentable` with a new day-of-the-week aspect ratio value.
  public func dayOfWeekAspectRatio(_ dayOfWeekAspectRatio: CGFloat) -> Self {
    var view = self
    view.dayOfWeekAspectRatio = dayOfWeekAspectRatio
    return view
  }

  /// Configures the amount of spacing, in points, between months. The default value is `0`.
  ///
  /// - Parameters:
  ///   - interMonthSpacing: The amount of spacing, in points, between months.
  /// - Returns: A new `CalendarViewRepresentable` with a new inter-month-spacing value.
  public func interMonthSpacing(_ interMonthSpacing: CGFloat) -> Self {
    var view = self
    view.interMonthSpacing = interMonthSpacing
    return view
  }

  /// Configures the amount to inset days and day-of-week items from the edges of a month. The default value is `.zero`.
  ///
  /// - Parameters:
  ///   - monthDayInsets: The amount to inset days and day-of-week items from the edges of a month.
  /// - Returns: A new `CalendarViewRepresentable` with a new month-day-insets value.
  public func monthDayInsets(_ monthDayInsets: NSDirectionalEdgeInsets) -> Self {
    var view = self
    view.monthDayInsets = monthDayInsets
    return view
  }

  /// Configures the amount of space between two day frames vertically.
  ///
  /// If `verticalDayMargin` and `horizontalDayMargin` are the same, then each day will appear to
  /// have a 1:1 (square) aspect ratio. If `verticalDayMargin` and `horizontalDayMargin` are different, then days can
  /// appear wider or taller.
  ///
  /// - Parameters:
  ///   - verticalDayMargin: The amount of space between two day frames along the vertical axis.
  /// - Returns: A new `CalendarViewRepresentable` with a new vertical day margin value.
  public func verticalDayMargin(_ verticalDayMargin: CGFloat) -> Self {
    var view = self
    view.verticalDayMargin = verticalDayMargin
    return view
  }

  /// Configures the amount of space between two day frames horizontally.
  ///
  /// If `verticalDayMargin` and `horizontalDayMargin` are the same, then each day will appear to
  /// have a 1:1 (square) aspect ratio. If `verticalDayMargin` and `horizontalDayMargin` are
  /// different, then days can appear wider or taller.
  ///
  /// - Parameters:
  ///   - horizontalDayMargin: The amount of space between two day frames along the horizontal axis.
  /// - Returns: A new `CalendarViewRepresentable` with a new horizontal day margin value.
  public func horizontalDayMargin(_ horizontalDayMargin: CGFloat) -> Self {
    var view = self
    view.horizontalDayMargin = horizontalDayMargin
    return view
  }

  /// Configures the days-of-the-week row's separator options. The separator appears below the days-of-the-week row.
  ///
  /// - Parameters:
  ///   - options: An instance that has properties to control various aspects of the separator's design.
  /// - Returns: A new `CalendarViewRepresentable` with a days-of-the-week row separator configured.
  public func daysOfTheWeekRowSeparator(
    options daysOfTheWeekRowSeparatorOptions: DaysOfTheWeekRowSeparatorOptions?)
    -> Self
  {
    var view = self
    view.daysOfTheWeekRowSeparatorOptions = daysOfTheWeekRowSeparatorOptions
    return view
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
  /// - Returns: A new `CalendarViewRepresentable` with a new month header item provider.
  public func monthHeaderItemProvider(
    _ monthHeaderItemProvider: @escaping (_ month: Month) -> AnyCalendarItemModel)
    -> Self
  {
    var view = self
    view.monthHeaderItemProvider = monthHeaderItemProvider
    return view
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
  /// - Returns: A new `CalendarViewRepresentable` with a new day-of-week item provider.
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
  /// - Returns: A new `CalendarViewRepresentable` with a new day item provider.
  public func dayItemProvider(
    _ dayItemProvider: @escaping (_ day: Day) -> AnyCalendarItemModel)
    -> Self
  {
    var view = self
    view.dayItemProvider = dayItemProvider
    return view
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
  /// - Returns: A new `CalendarViewRepresentable` with a new day background item provider.
  public func dayBackgroundItemProvider(
    _ dayBackgroundItemProvider: @escaping (_ day: Day) -> AnyCalendarItemModel?)
    -> Self
  {
    var view = self
    view.dayBackgroundItemProvider = dayBackgroundItemProvider
    return view
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
  /// - Returns: A new `CalendarViewRepresentable` with a new month background item provider.
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

  /// Configures the day range item provider.
  ///
  /// `CalendarView` invokes the provided `dayRangeItemProvider` for each day range in the `dateRanges` set.
  /// Date ranges will be converted to day ranges by using the `calendar`passed into the `CalendarViewRepresentable`
  /// initializer. The `CalendarItemModel` that you return for each day range will be used to create a view that spans the entire
  /// frame encapsulating all days in that day range. This behavior makes day range items useful for things like day range selection
  /// indicators that might have specific styling requirements for different parts of the selected day range. For example, you might have
  /// a cross fade in your day range selection indicator view when a day range spans multiple months, or you might have rounded end
  /// caps for the start and end of a day range.
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
  /// - Returns: A new `CalendarViewRepresentable` with a new day range item provider.
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
  /// - Returns: A new `CalendarViewRepresentable` with a new overlay item provider.
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

  /// Configures the day-selection handler.
  ///
  /// It is the responsibility of your feature code to decide what to do with each day. For example, you might store the most recent day
  /// in a selected day property, then read that property in your `dayItemProvider` closure to add specific "selected" styling to a
  /// particular day view. If one of your item provider closures depends on this selected day state, remember to include it as part of the
  /// `dataDependency` parameter when initializing your `CalendarViewRepresentable`.
  ///
  /// - Parameters:
  ///   - daySelectionHandler: A closure (that is retained) that is invoked whenever a day is selected.
  public func onDaySelection(_ daySelectionHandler: @escaping (Day) -> Void) -> Self {
    var view = self
    view.daySelectionHandler = daySelectionHandler
    return view
  }

  /// Configures the multiple-day-selection drag handler.
  ///
  /// Multiple selection is initiated with a long press, followed by a drag / pan. As the gesture crosses over more days in the calendar,
  /// this handler will be invoked with each new day. It is the responsibility of your feature code to decide what to do with this stream of
  /// days. For example, you might convert them to `Date` instances and use them as input to the `dayRangeItemProvider`. If
  /// one of your item provider closures depends on state referencing this stream of selected days, remember to include it as part of
  /// the `dataDependency` parameter when initializing your `CalendarViewRepresentable`.
  ///
  /// - Parameters:
  ///   - began: A closure (that is retained) that is invoked when the multiple-day-selection drag gesture begins.
  ///   - changed: A closure (that is retained) that is invoked when the multiple-day-selection drag gesture intersects a new day.
  ///   - ended: A closure (that is retained) that is invoked when the multiple-day-selection drag gesture ends.
  public func onMultipleDaySelectionDrag(
    began: @escaping (Day) -> Void,
    changed: @escaping (Day) -> Void,
    ended: @escaping (Day) -> Void)
    -> Self
  {
    var view = self
    view.multiDaySelectionDragHandler = { day, state in
      switch state {
      case .began:
        began(day)
      case .changed:
        changed(day)
      case .ended, .failed, .cancelled:
        ended(day)
      default:
        break
      }
    }
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

@available(iOS 13.0, *)
extension CalendarViewRepresentable {

  // MARK: Public

  // Pre-iOS-16 support
  public func _overrideSizeThatFits(
    _ size: inout CGSize,
    in proposedSize: _ProposedSize,
    uiView: CalendarView)
  {
    let children = Mirror(reflecting: proposedSize).children
    let proposedSize = CGSize(
      width: children.first { $0.label == "width" }?.value as? CGFloat ?? .infinity,
      height: children.first { $0.label == "height" }?.value as? CGFloat ?? .infinity)

    size = sizeThatFits(proposedSize, uiView: uiView)
  }

  // Post-iOS-16 support
  #if swift(>=5.7)
  @available(iOS 16.0, *)
  public func sizeThatFits(
    _ proposal: ProposedViewSize,
    uiView: CalendarView,
    context _: Context)
    -> CGSize?
  {
    sizeThatFits(
      CGSize(width: proposal.width ?? .infinity, height: proposal.height ?? .infinity),
      uiView: uiView)
  }
  #endif

  // MARK: Private

  private func sizeThatFits(_ proposal: CGSize, uiView: CalendarView) -> CGSize {
    switch monthsLayout {
    case .vertical:
      return proposal

    case .horizontal:
      let _insetsLayoutMarginsFromSafeArea = uiView.insetsLayoutMarginsFromSafeArea

      // We need to set this to false, otherwise the sizing calculation will include inherited layout
      // margins. For some reason, this is only an issue in SwiftUI, not UIKit.
      uiView.insetsLayoutMarginsFromSafeArea = false

      let width = min(proposal.width, .maxLayoutValue)
      let height = min(proposal.height, .maxLayoutValue)

      let size = uiView.systemLayoutSizeFitting(
        CGSize(width: width, height: height),
        withHorizontalFittingPriority: .required,
        verticalFittingPriority: .fittingSizeLevel)

      uiView.insetsLayoutMarginsFromSafeArea = _insetsLayoutMarginsFromSafeArea

      return CGSize(width: proposal.width, height: size.height)
    }

  }

}
