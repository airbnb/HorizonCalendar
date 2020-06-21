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

import CoreGraphics
import Foundation

/// Provides frame and size information about all core layout items. The calendar is laid out lazily, starting with an initial known layout
/// frame (like the frame of an initially visible month header). All subsequent layout calculations are done by laying out items adjacent to
/// a known layout frame. The results of those calculations can then be used for future layout calculations.
final class FrameProvider {

  // MARK: Lifecycle

  init(
    content: CalendarViewContent,
    size: CGSize,
    scale: CGFloat,
    monthHeaderHeight: CGFloat)
  {
    self.content = content
    self.size = size
    self.scale = scale
    self.monthHeaderHeight = monthHeaderHeight

    switch content.monthsLayout {
    case .vertical:
      monthWidth = size.width
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
      let rowInMonth = calendar.rowInMonth(for: calendar.startDate(of: day))

      let x = minXOfMonth(containingItemWithFrame: layoutItem.frame, at: position)
      let y = layoutItem.frame.minY -
        (CGFloat(rowInMonth) * (daySize.height + content.verticalDayMargin)) -
        (monthsLayout.pinDaysOfWeekToTop ? 0 : (daySize.height + content.verticalDayMargin)) -
        content.monthDayInsets.top -
        monthHeaderHeight

      return CGPoint(x: x, y: y)
    }
  }

  func originOfMonth(
    _ month: Month,
    beforeMonthWithOrigin subsequentMonthOrigin: CGPoint)
    -> CGPoint
  {
    switch monthsLayout {
    case .vertical(let pinDaysOfWeekToTop):
      let numberOfRows = calendar.numberOfRows(in: month)
      let monthHeight = monthHeaderHeight +
        content.monthDayInsets.top +
        (pinDaysOfWeekToTop ? 0 : (daySize.height + content.verticalDayMargin)) +
        (CGFloat(numberOfRows) * (daySize.height + content.verticalDayMargin)) +
        content.monthDayInsets.bottom
      return CGPoint(
        x: subsequentMonthOrigin.x,
        y: subsequentMonthOrigin.y - content.interMonthSpacing - monthHeight)

    case .horizontal:
      return CGPoint(
        x: subsequentMonthOrigin.x - content.interMonthSpacing - monthWidth,
        y: subsequentMonthOrigin.y)
    }
  }

  func originOfMonth(
    _ month: Month,
    afterMonthWithOrigin previousMonthOrigin: CGPoint)
    -> CGPoint
  {
    switch monthsLayout {
    case .vertical(let pinDaysOfWeekToTop):
      let previousMonth = calendar.month(byAddingMonths: -1, to: month)
      let numberOfRows = calendar.numberOfRows(in: previousMonth)
      let previousMonthHeight = monthHeaderHeight +
        content.monthDayInsets.top +
        (pinDaysOfWeekToTop ? 0 : (daySize.height + content.verticalDayMargin)) +
        (CGFloat(numberOfRows) * (daySize.height + content.verticalDayMargin)) +
        content.monthDayInsets.bottom
      return CGPoint(
        x: previousMonthOrigin.x,
        y: previousMonthOrigin.y + previousMonthHeight + content.interMonthSpacing)

    case .horizontal:
      return CGPoint(
        x: previousMonthOrigin.x + monthWidth + content.interMonthSpacing,
        y: previousMonthOrigin.y)
    }
  }

  func frameOfMonth(
    _ month: Month,
    withOrigin monthOrigin: CGPoint)
    -> CGRect
  {
    let lastDate = calendar.lastDate(of: month)
    let frameOfLastDayOfCurrentMonth = frameOfDay(
      calendar.day(containing: lastDate),
      inMonthWithOrigin: monthOrigin)
    let monthHeight = frameOfLastDayOfCurrentMonth.maxY - monthOrigin.y

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

  func frameOfDayOfWeekBackground(inMonthWithOrigin monthOrigin: CGPoint) -> CGRect {
    let y = monthOrigin.y + monthHeaderHeight + content.monthDayInsets.top
    return CGRect(x: monthOrigin.x, y: y, width: monthWidth, height: daySize.height)
  }

  func frameOfDay(_ day: Day, inMonthWithOrigin monthOrigin: CGPoint) -> CGRect {
    let date = calendar.startDate(of: day)
    let dayOfWeekPosition = calendar.dayOfWeekPosition(for: date)
    let rowInMonth = calendar.rowInMonth(for: date)

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
    let x = content.monthDayInsets.left +
      (CGFloat(dayOfWeekPosition.rawValue - 1) * (daySize.width + content.horizontalDayMargin))
    return CGRect(origin: CGPoint(x: x, y: yContentOffset), size: daySize)
  }

  func frameOfPinnedDayOfWeekBackground(yContentOffset: CGFloat) -> CGRect {
    CGRect(x: 0, y: yContentOffset, width: monthWidth, height: daySize.height)
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
        Calendar metrics and bounds resulted in a negative or zero size of \( daySize.width) for
        each day.
      """)

    if case .horizontal = monthsLayout {
      let maxNumberOfWeekRowsPerMonth = CGFloat(6)

      let insetHeight = size.height - content.monthDayInsets.top - content.monthDayInsets.bottom
      let availableHeight = insetHeight -
        monthHeaderHeight -
        daySize.height -
        ((daySize.height + content.verticalDayMargin) * maxNumberOfWeekRowsPerMonth)
      let points = availableHeight / maxNumberOfWeekRowsPerMonth

      assert(
        points > 0,
        """
          Calendar metrics and bounds resulted in a negative or zero size of \(points) for each day.
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

}
