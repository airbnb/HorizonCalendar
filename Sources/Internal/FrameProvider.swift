// Created by Bryan Keller on 3/29/20.
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

import os.log
import UIKit

/// Provides frame and size information about all core layout items. The calendar is laid out lazily, starting with an initial known layout
/// frame (like the frame of an initially visible month header). All subsequent layout calculations are done by laying out items adjacent to
/// a known layout frame. The results of those calculations can then be used for future layout calculations.
final class FrameProvider {

  // MARK: Lifecycle

  init(
    content: CalendarViewContent,
    size: CGSize,
    layoutMargins: NSDirectionalEdgeInsets,
    scale: CGFloat)
  {
    self.content = content
    self.size = size
    self.layoutMargins = layoutMargins
    self.scale = scale

    switch content.monthsLayout {
    case .vertical:
      monthWidth = size.width - layoutMargins.leading - layoutMargins.trailing
    case .horizontal(let options):
      monthWidth = options.monthWidth(
        calendarWidth: size.width,
        interMonthSpacing: content.interMonthSpacing)
    }

    let insetWidth = monthWidth - content.monthDayInsets.leading - content.monthDayInsets.trailing
    let numberOfDaysPerWeek = CGFloat(7)
    let availableWidth = insetWidth - (content.horizontalDayMargin * (numberOfDaysPerWeek - 1))
    let width = availableWidth / numberOfDaysPerWeek

    let dayHeight = width * content.dayAspectRatio
    daySize = CGSize(width: width, height: dayHeight)

    let dayOfWeekHeight = width * content.dayOfWeekAspectRatio
    dayOfWeekSize = CGSize(width: width, height: dayOfWeekHeight)

    if daySize.width <= 0 || daySize.height <= 0 {
      os_log(
        "Calendar metrics and size resulted in a negative-or-zero size of (%@ points for each day. If ignored, this will cause incorrect / unexpected layouts.",
        log: .default,
        type: .debug,
        daySize.debugDescription)
    }
  }

  // MARK: Internal

  let size: CGSize
  let layoutMargins: NSDirectionalEdgeInsets
  let scale: CGFloat
  let daySize: CGSize
  let dayOfWeekSize: CGSize

  func maxMonthHeight(monthHeaderHeight: CGFloat) -> CGFloat {
    monthHeaderHeight +
      content.monthDayInsets.top +
      heightOfDaysOfTheWeekRowInMonth() +
      heightOfDayContent(forNumberOfWeekRows: 6) +
      content.monthDayInsets.bottom
  }

  // MARK: Month locations

  func originOfMonth(
    containing layoutItem: LayoutItem,
    monthHeaderHeight: CGFloat)
    -> CGPoint
  {
    switch layoutItem.itemType {
    case .monthHeader:
      return layoutItem.frame.origin

    case .dayOfWeekInMonth(let position, _):
      let x = minXOfMonth(containingItemWithFrame: layoutItem.frame, at: position)
      let y = layoutItem.frame.minY - content.monthDayInsets.top - monthHeaderHeight
      return CGPoint(x: x, y: y)

    case .day(let day):
      let position = calendar.dayOfWeekPosition(for: calendar.startDate(of: day))
      let rowInMonth = adjustedRowInMonth(for: day)

      let x = minXOfMonth(containingItemWithFrame: layoutItem.frame, at: position)
      let y = minYOfMonth(
        containingDayItemWithFrame: layoutItem.frame,
        atRowInMonth: rowInMonth,
        monthHeaderHeight: monthHeaderHeight)
      return CGPoint(x: x, y: y)
    }
  }

  func originOfMonth(
    _ month: Month,
    beforeMonthWithOrigin subsequentMonthOrigin: CGPoint,
    subsequentMonthHeaderHeight: CGFloat,
    monthHeaderHeight: CGFloat)
    -> CGPoint
  {
    switch monthsLayout {
    case .vertical:
      let monthHeight = heightOfMonth(month, monthHeaderHeight: monthHeaderHeight)
      return CGPoint(
        x: subsequentMonthOrigin.x,
        y: subsequentMonthOrigin.y - content.interMonthSpacing - monthHeight)

    case .horizontal:
      return CGPoint(
        x: subsequentMonthOrigin.x - content.interMonthSpacing - monthWidth,
        y: subsequentMonthOrigin.y + subsequentMonthHeaderHeight - monthHeaderHeight)
    }
  }

  func originOfMonth(
    _ month: Month,
    afterMonthWithOrigin previousMonthOrigin: CGPoint,
    previousMonthHeaderHeight: CGFloat,
    monthHeaderHeight: CGFloat)
    -> CGPoint
  {
    switch monthsLayout {
    case .vertical:
      let previousMonth = calendar.month(byAddingMonths: -1, to: month)
      let previousMonthHeight = heightOfMonth(
        previousMonth,
        monthHeaderHeight: previousMonthHeaderHeight)
      return CGPoint(
        x: previousMonthOrigin.x,
        y: previousMonthOrigin.y + previousMonthHeight + content.interMonthSpacing)

    case .horizontal:
      return CGPoint(
        x: previousMonthOrigin.x + monthWidth + content.interMonthSpacing,
        y: previousMonthOrigin.y + previousMonthHeaderHeight - monthHeaderHeight)
    }
  }

  func frameOfMonth(
    _ month: Month,
    withOrigin monthOrigin: CGPoint,
    monthHeaderHeight: CGFloat)
    -> CGRect
  {
    let monthHeight = heightOfMonth(month, monthHeaderHeight: monthHeaderHeight)
    return CGRect(origin: monthOrigin, size: CGSize(width: monthWidth, height: monthHeight))
  }

  // MARK: Frames of core layout items

  func frameOfMonthHeader(
    inMonthWithOrigin monthOrigin: CGPoint,
    monthHeaderHeight: CGFloat)
    -> CGRect
  {
    CGRect(origin: monthOrigin, size: CGSize(width: monthWidth, height: monthHeaderHeight))
  }

  func frameOfDayOfWeek(
    at dayOfWeekPosition: DayOfWeekPosition,
    inMonthWithOrigin monthOrigin: CGPoint,
    monthHeaderHeight: CGFloat)
    -> CGRect
  {
    let x = minXOfItem(at: dayOfWeekPosition, minXOfContainingRow: monthOrigin.x)
    let y = monthOrigin.y + monthHeaderHeight + content.monthDayInsets.top
    return CGRect(origin: CGPoint(x: x, y: y), size: dayOfWeekSize)
  }

  func frameOfDay(
    _ day: Day,
    inMonthWithOrigin monthOrigin: CGPoint,
    monthHeaderHeight: CGFloat)
    -> CGRect
  {
    let date = calendar.startDate(of: day)
    let dayOfWeekPosition = calendar.dayOfWeekPosition(for: date)
    let rowInMonth = adjustedRowInMonth(for: day)
    let numberOfWeekRowsThroughDay = rowInMonth + 1

    let x = minXOfItem(at: dayOfWeekPosition, minXOfContainingRow: monthOrigin.x)
    let y = monthOrigin.y +
      monthHeaderHeight +
      content.monthDayInsets.top +
      heightOfDaysOfTheWeekRowInMonth() +
      heightOfDayContent(forNumberOfWeekRows: numberOfWeekRowsThroughDay) -
      daySize.height
    return CGRect(origin: CGPoint(x: x, y: y), size: daySize)
  }

  // A faster alternative to `frameOfDay(_:inMonthWithOrigin:)`, which uses the known frame of a
  // previously-laid-out adjacent day in the same month to determine the new day's frame without
  // needing to call `Calendar.rowInMonth(for:)` or create a `DayOfWeekPosition`. For
  // example, if the frame of Sept 12 is known, we can derive the frame of Sept 11 and Sept 13.
  func frameOfDay(
    _ day: Day,
    adjacentTo adjacentDay: Day,
    withFrame adjacentDayFrame: CGRect,
    inMonthWithOrigin monthOrigin: CGPoint)
    -> CGRect
  {
    let distanceFromAdjacentDay = day.day - adjacentDay.day
    guard
      day.month == adjacentDay.month,
      abs(distanceFromAdjacentDay) == 1
    else {
      preconditionFailure("\(day) must be adjacent to \(adjacentDay) (one day apart, same month).")
    }

    let minX = monthOrigin.x + content.monthDayInsets.leading
    let maxX = monthOrigin.x + monthWidth - content.monthDayInsets.trailing - daySize.width

    let origin: CGPoint
    if distanceFromAdjacentDay < 0 {
      let proposedX = adjacentDayFrame.minX - content.horizontalDayMargin - daySize.width
      if proposedX > minX || proposedX.isEqual(to: minX, screenScale: scale) {
        origin = CGPoint(x: proposedX, y: adjacentDayFrame.minY)
      } else {
        origin = CGPoint(
          x: maxX,
          y: adjacentDayFrame.minY - content.verticalDayMargin - daySize.height)
      }
    } else {
      let proposedX = adjacentDayFrame.maxX + content.horizontalDayMargin
      if proposedX < maxX || proposedX.isEqual(to: maxX, screenScale: scale) {
        origin = CGPoint(x: proposedX, y: adjacentDayFrame.minY)
      } else {
        origin = CGPoint(x: minX, y: adjacentDayFrame.maxY + content.verticalDayMargin)
      }
    }

    return CGRect(origin: origin, size: daySize)
  }

  // MARK: Misc item frames

  func frameOfPinnedDayOfWeek(
    at dayOfWeekPosition: DayOfWeekPosition,
    yContentOffset: CGFloat)
    -> CGRect
  {
    let x = minXOfItem(at: dayOfWeekPosition, minXOfContainingRow: layoutMargins.leading)
    let y = layoutMargins.top + yContentOffset
    return CGRect(origin: CGPoint(x: x, y: y), size: dayOfWeekSize)
  }

  func frameOfPinnedDaysOfWeekRowBackground(yContentOffset: CGFloat) -> CGRect {
    CGRect(
      x: layoutMargins.leading,
      y: layoutMargins.top + yContentOffset,
      width: monthWidth,
      height: dayOfWeekSize.height)
  }

  func frameOfPinnedDaysOfWeekRowSeparator(
    yContentOffset: CGFloat,
    separatorHeight: CGFloat)
    -> CGRect
  {
    CGRect(
      x: layoutMargins.leading,
      y: layoutMargins.top + yContentOffset + dayOfWeekSize.height - separatorHeight,
      width: monthWidth,
      height: separatorHeight)
  }

  func frameOfDaysOfWeekRowSeparator(
    inMonthWithOrigin monthOrigin: CGPoint,
    separatorHeight: CGFloat,
    monthHeaderHeight: CGFloat)
    -> CGRect
  {
    let y = monthOrigin.y +
      monthHeaderHeight +
      content.monthDayInsets.top +
      dayOfWeekSize.height -
      separatorHeight
    return CGRect(x: monthOrigin.x, y: y, width: monthWidth, height: separatorHeight)
  }

  // MARK: Scroll-to-item Frames

  /// Returns translated item frames for the specified scroll offset and scroll position. Note that the returned frames may not be at valid
  /// resting positions. For example, someone could try to scroll the last day in the calendar to be at a vertically-centered scroll
  /// position, which would cause the calendar to be laid out in an over-scrolled position. The `VisibleItemsProvider` will detect
  /// this scenario and adjust the frame so it's at a valid resting position.
  func frameOfItem(
    withOriginalFrame originalFrame: CGRect,
    at scrollPosition: CalendarViewScrollPosition,
    offset: CGPoint)
    -> CGRect
  {
    switch content.monthsLayout {
    case .vertical(let options):
      let additionalOffset = (options.pinDaysOfWeekToTop ? dayOfWeekSize.height : 0)
      let minY = offset.y + additionalOffset
      let maxY = offset.y + size.height
      let firstFullyVisibleY = minY
      let lastFullyVisibleY = maxY - originalFrame.height
      let y: CGFloat
      switch scrollPosition {
      case .centered:
        y = minY + ((maxY - minY) / 2) - (originalFrame.height / 2)
      case .firstFullyVisiblePosition(let padding):
        y = firstFullyVisibleY + padding
      case .lastFullyVisiblePosition(let padding):
        y = lastFullyVisibleY - padding
      }

      return CGRect(
        x: originalFrame.minX,
        y: y,
        width: originalFrame.width,
        height: originalFrame.height)

    case .horizontal:
      let minX = offset.x
      let maxX = offset.x + size.width
      let firstFullyVisibleX = minX
      let lastFullyVisibleX = maxX - originalFrame.width
      let x: CGFloat
      switch scrollPosition {
      case .centered:
        x = minX + ((maxX - minX) / 2) - (originalFrame.width / 2)
      case .firstFullyVisiblePosition(let padding):
        x = firstFullyVisibleX + padding
      case .lastFullyVisiblePosition(let padding):
        x = lastFullyVisibleX - padding
      }

      return CGRect(
        x: x,
        y: originalFrame.minY,
        width: originalFrame.width,
        height: originalFrame.height)
    }
  }

  // MARK: Private

  private let content: CalendarViewContent
  private let monthWidth: CGFloat

  private var calendar: Calendar {
    content.calendar
  }

  private var monthsLayout: MonthsLayout {
    content.monthsLayout
  }

  private func minXOfItem(
    at dayOfWeekPosition: DayOfWeekPosition,
    minXOfContainingRow: CGFloat)
    -> CGFloat
  {
    let distanceFromMonthLeadingEdge = CGFloat(dayOfWeekPosition.rawValue - 1) *
      (daySize.width + content.horizontalDayMargin)
    return minXOfContainingRow + content.monthDayInsets.leading + distanceFromMonthLeadingEdge
  }

  private func minXOfMonth(
    containingItemWithFrame itemFrame: CGRect,
    at dayOfWeekPosition: DayOfWeekPosition)
    -> CGFloat
  {
    let distanceFromMinXOfMonth = minXOfItem(at: dayOfWeekPosition, minXOfContainingRow: 0)
    return itemFrame.minX - distanceFromMinXOfMonth
  }

  private func minYOfMonth(
    containingDayItemWithFrame dayItemFrame: CGRect,
    atRowInMonth rowInMonth: Int,
    monthHeaderHeight: CGFloat)
    -> CGFloat
  {
    dayItemFrame.minY -
      ((daySize.height + content.verticalDayMargin) * CGFloat(rowInMonth)) -
      heightOfDaysOfTheWeekRowInMonth() -
      content.monthDayInsets.top -
      monthHeaderHeight
  }

  private func heightOfMonth(_ month: Month, monthHeaderHeight: CGFloat) -> CGFloat {
    let numberOfWeekRows = numberOfWeekRows(in: month)
    return monthHeaderHeight +
      content.monthDayInsets.top +
      heightOfDaysOfTheWeekRowInMonth() +
      heightOfDayContent(forNumberOfWeekRows: numberOfWeekRows) +
      content.monthDayInsets.bottom
  }

  // Gets the row of a date in a particular month, taking into account whether the date is in a
  // boundary month that's only showing some dates.
  private func adjustedRowInMonth(for day: Day) -> Int {
    guard day >= content.dayRange.lowerBound else {
      preconditionFailure("""
          Cannot get the adjusted row for \(day), which is lower than the first day in the visible day
          range (\(content.dayRange)).
        """)
    }

    let missingRows: Int
    if
      !content.monthsLayout.alwaysShowCompleteBoundaryMonths,
      day.month == content.monthRange.lowerBound
    {
      missingRows = calendar.rowInMonth(for: calendar.startDate(of: content.dayRange.lowerBound))
    } else {
      missingRows = 0
    }

    let rowInMonth = calendar.rowInMonth(for: calendar.startDate(of: day))
    return rowInMonth - missingRows
  }

  // Gets the number of week rows in a particular month, taking into account whether the month is a
  // boundary month that's only showing a subset of days.
  private func numberOfWeekRows(in month: Month) -> Int {
    let rowOfLastDateInMonth: Int
    if month == content.monthRange.lowerBound, month == content.monthRange.upperBound {
      let firstDayOfOnlyMonth = content.dayRange.lowerBound
      let lastDayOfOnlyMonth = content.dayRange.upperBound
      let rowOfFirstDayOfOnlyMonth = adjustedRowInMonth(for: firstDayOfOnlyMonth)
      let rowOfLastDayOfOnlyMonth = adjustedRowInMonth(for: lastDayOfOnlyMonth)
      rowOfLastDateInMonth = rowOfLastDayOfOnlyMonth - rowOfFirstDayOfOnlyMonth
    } else if month == content.monthRange.lowerBound {
      let lastDateOfFirstMonth = calendar.lastDate(of: month)
      let lastDayOfFirstMonth = calendar.day(containing: lastDateOfFirstMonth)
      let rowOfLastDayOfFirstMonth = adjustedRowInMonth(for: lastDayOfFirstMonth)
      rowOfLastDateInMonth = rowOfLastDayOfFirstMonth
    } else if month == content.monthRange.upperBound {
      let lastDayOfLastMonth = content.dayRange.upperBound
      let rowOfLastDayOfLastMonth = adjustedRowInMonth(for: lastDayOfLastMonth)
      rowOfLastDateInMonth = rowOfLastDayOfLastMonth
    } else {
      let lastDateOfMonth = calendar.lastDate(of: month)
      rowOfLastDateInMonth = calendar.rowInMonth(for: lastDateOfMonth)
    }

    return rowOfLastDateInMonth + 1
  }

  // Gets the height of day content for a specified number of week rows, including the additional
  // height for vertical day padding.
  // For example, the returned height value for 5 week rows will be 5x the `daySize.height`, plus 4x
  // the `content.verticalDayMargin`.
  private func heightOfDayContent(forNumberOfWeekRows numberOfWeekRows: Int) -> CGFloat {
    guard numberOfWeekRows > 0 else {
      fatalError("Cannot calculate the height of day content if `numberOfWeekRows` is <= 0.")
    }
    return (CGFloat(numberOfWeekRows) * daySize.height) +
      (CGFloat(numberOfWeekRows - 1) * content.verticalDayMargin)
  }

  // Gets the height of the days of the week row, plus the padding between it and the first row of
  // days in each month. The returned value will be `0` if
  // `monthsLayout.pinDaysOfWeekToTop == true`.
  private func heightOfDaysOfTheWeekRowInMonth() -> CGFloat {
    monthsLayout.pinDaysOfWeekToTop ? 0 : (dayOfWeekSize.height + content.verticalDayMargin)
  }

}
