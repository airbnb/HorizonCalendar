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
    scale: CGFloat,
    monthHeaderHeight: CGFloat)
  {
    self.content = content
    self.size = size
    self.layoutMargins = layoutMargins
    self.scale = scale
    self.monthHeaderHeight = monthHeaderHeight

    switch content.monthsLayout {
    case .vertical:
      monthWidth = size.width - layoutMargins.leading - layoutMargins.trailing
    case .horizontal(let _monthWidth):
      monthWidth = _monthWidth
    }

    let insetWidth = monthWidth - content.monthDayInsets.left - content.monthDayInsets.right
    let numberOfDaysPerWeek = CGFloat(7)
    let availableWidth = insetWidth - (content.horizontalDayMargin * (numberOfDaysPerWeek - 1))
    let points = availableWidth / numberOfDaysPerWeek
    daySize = CGSize(width: points, height: points)

    validateCalendarMetrics(size: size)
  }

  // MARK: Internal

  let size: CGSize
  let layoutMargins: NSDirectionalEdgeInsets
  let scale: CGFloat
  let daySize: CGSize

  // MARK: Month locations

  func originOfMonth(containing layoutItem: LayoutItem) -> CGPoint {
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
      let y = minYOfMonth(containingDayItemWithFrame: layoutItem.frame, atRowInMonth: rowInMonth)
      return CGPoint(x: x, y: y)
    }
  }

  func originOfMonth(
    _ month: Month,
    beforeMonthWithOrigin subsequentMonthOrigin: CGPoint)
    -> CGPoint
  {
    switch monthsLayout {
    case .vertical:
      let monthHeight = heightOfMonth(month)
      return CGPoint(
        x: subsequentMonthOrigin.x,
        y: subsequentMonthOrigin.y - content.interMonthSpacing - monthHeight)

    case .horizontal:
      return CGPoint(
        x: subsequentMonthOrigin.x - content.interMonthSpacing - monthWidth,
        y: subsequentMonthOrigin.y)
    }
  }

  func originOfMonth(_ month: Month, afterMonthWithOrigin previousMonthOrigin: CGPoint) -> CGPoint {
    switch monthsLayout {
    case .vertical:
      let previousMonth = calendar.month(byAddingMonths: -1, to: month)
      let previousMonthHeight = heightOfMonth(previousMonth)
      return CGPoint(
        x: previousMonthOrigin.x,
        y: previousMonthOrigin.y + previousMonthHeight + content.interMonthSpacing)

    case .horizontal:
      return CGPoint(
        x: previousMonthOrigin.x + monthWidth + content.interMonthSpacing,
        y: previousMonthOrigin.y)
    }
  }

  func frameOfMonth(_ month: Month, withOrigin monthOrigin: CGPoint) -> CGRect {
    let monthHeight = heightOfMonth(month)
    return CGRect(origin: monthOrigin, size: CGSize(width: monthWidth, height: monthHeight))
  }

  // MARK: Frames of core layout items

  func frameOfMonthHeader(inMonthWithOrigin monthOrigin: CGPoint) -> CGRect {
    CGRect(origin: monthOrigin, size: CGSize(width: monthWidth, height: monthHeaderHeight))
  }

  func frameOfDayOfWeek(
    at dayOfWeekPosition: DayOfWeekPosition,
    inMonthWithOrigin monthOrigin: CGPoint)
    -> CGRect
  {
    let x = monthOrigin.x +
      content.monthDayInsets.left +
      (CGFloat(dayOfWeekPosition.rawValue - 1) * (daySize.width + content.horizontalDayMargin))
    let y = monthOrigin.y + monthHeaderHeight + content.monthDayInsets.top
    return CGRect(origin: CGPoint(x: x, y: y), size: daySize)
  }

  func frameOfDay(_ day: Day, inMonthWithOrigin monthOrigin: CGPoint) -> CGRect {
    let date = calendar.startDate(of: day)
    let dayOfWeekPosition = calendar.dayOfWeekPosition(for: date)
    let rowInMonth = adjustedRowInMonth(for: day)

    let x = monthOrigin.x +
      content.monthDayInsets.left +
      (CGFloat(dayOfWeekPosition.rawValue - 1) * (daySize.width + content.horizontalDayMargin))
    let y = monthOrigin.y +
      monthHeaderHeight +
      content.monthDayInsets.top +
      (monthsLayout.pinDaysOfWeekToTop ? 0 : (daySize.height + content.verticalDayMargin)) +
      (CGFloat(rowInMonth) * (daySize.height + content.verticalDayMargin))
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
    else
    {
      preconditionFailure("\(day) must be adjacent to \(adjacentDay) (one day apart, same month).")
    }

    let minX = monthOrigin.x + content.monthDayInsets.left
    let maxX = monthOrigin.x + monthWidth - content.monthDayInsets.right - daySize.width

    let origin: CGPoint
    if distanceFromAdjacentDay < 0 {
      let proposedX = adjacentDayFrame.minX - content.horizontalDayMargin - daySize.width
      if
        proposedX.alignedToPixel(forScreenWithScale: scale) >=
          minX.alignedToPixel(forScreenWithScale: scale)
      {
        origin = CGPoint(x: proposedX, y: adjacentDayFrame.minY)
      } else {
        origin = CGPoint(
          x: maxX,
          y: adjacentDayFrame.minY - content.verticalDayMargin - daySize.height)
      }
    } else {
      let proposedX = adjacentDayFrame.maxX + content.horizontalDayMargin
      if
        proposedX.alignedToPixel(forScreenWithScale: scale) <=
          maxX.alignedToPixel(forScreenWithScale: scale)
      {
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
    let x = layoutMargins.leading + content.monthDayInsets.left +
      (CGFloat(dayOfWeekPosition.rawValue - 1) * (daySize.width + content.horizontalDayMargin))
    return CGRect(origin: CGPoint(x: x, y: yContentOffset), size: daySize)
  }

  func frameOfPinnedDaysOfWeekRowBackground(yContentOffset: CGFloat) -> CGRect {
    CGRect(x: layoutMargins.leading, y: yContentOffset, width: monthWidth, height: daySize.height)
  }

  func frameOfPinnedDaysOfWeekRowSeparator(
    yContentOffset: CGFloat,
    separatorHeight: CGFloat)
    -> CGRect
  {
    CGRect(
      x: layoutMargins.leading,
      y: yContentOffset + daySize.height - separatorHeight,
      width: monthWidth,
      height: separatorHeight)
  }

  func frameOfDaysOfWeekRowSeparator(
    inMonthWithOrigin monthOrigin: CGPoint,
    separatorHeight: CGFloat) -> CGRect
  {
    CGRect(
      x: monthOrigin.x,
      y: monthOrigin.y + monthHeaderHeight + content.monthDayInsets.top + daySize.height -
        separatorHeight,
      width: monthWidth,
      height: separatorHeight)
  }

  // MARK: Private

  private let content: CalendarViewContent
  private let monthWidth: CGFloat
  private let monthHeaderHeight: CGFloat

  private var calendar: Calendar {
    content.calendar
  }

  private var monthsLayout: MonthsLayout {
    content.monthsLayout
  }

  private func validateCalendarMetrics(size: CGSize) {
    assert(
      daySize.width > 0,
      """
        Calendar metrics and size resulted in a negative-or-zero size of \(daySize.width) points for
        each day. If ignored, this will cause very odd / incorrect layouts.
      """)

    if case .horizontal = monthsLayout {
      let maxNumberOfWeekRowsPerMonth = CGFloat(6)

      let availableHeight = size.height -
        monthHeaderHeight -
        content.monthDayInsets.top -
        daySize.height - content.verticalDayMargin -
        (maxNumberOfWeekRowsPerMonth * daySize.height) -
        ((maxNumberOfWeekRowsPerMonth - 1) * content.verticalDayMargin) -
        content.monthDayInsets.bottom

      assert(
        availableHeight > 0,
        """
          Calendar metrics and size resulted in a negative-or-zero amount of remaining height
          (\(availableHeight) points) after allocating room for calendar elements. If ignored, this
          will cause very odd / incorrect layouts.
        """)
    }
  }

  private func minXOfMonth(
    containingItemWithFrame itemFrame: CGRect,
    at dayOfWeekPosition: DayOfWeekPosition)
    -> CGFloat
  {
    itemFrame.minX -
      (CGFloat(dayOfWeekPosition.rawValue - 1) * (daySize.width + content.horizontalDayMargin)) -
      content.monthDayInsets.left
  }

  private func minYOfMonth(
    containingDayItemWithFrame dayItemFrame: CGRect,
    atRowInMonth rowInMonth: Int)
    -> CGFloat
  {
    dayItemFrame.minY -
      (CGFloat(rowInMonth) * (daySize.height + content.verticalDayMargin)) -
      (monthsLayout.pinDaysOfWeekToTop ? 0 : (daySize.height + content.verticalDayMargin)) -
      content.monthDayInsets.top -
      monthHeaderHeight
  }

  private func heightOfMonth(_ month: Month) -> CGFloat {
    let numberOfRows = self.numberOfRows(in: month)
    return monthHeaderHeight +
      content.monthDayInsets.top +
      (monthsLayout.pinDaysOfWeekToTop ? 0 : (daySize.height + content.verticalDayMargin)) +
      (CGFloat(numberOfRows) * daySize.height) +
      (CGFloat(numberOfRows - 1) * content.verticalDayMargin) +
      content.monthDayInsets.bottom
  }

  // Gets the row of a date in a particular month, taking into account whether the date is in a
  // boundary month that's only showing some dates.
  private func adjustedRowInMonth(for day: Day) -> Int {
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

  // Gets the number of rows in a particular month, taking into account whether the month is a
  // boundary month that's only showing some dates.
  private func numberOfRows(in month: Month) -> Int {
    let rowOfLastDateInMonth: Int
    if month == content.monthRange.lowerBound {
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

}
