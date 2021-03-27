// Created by Bryan Keller on 2/7/21.
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

final class AnchorLayoutItemsProvider {
  
  // MARK: Internal
  
  func anchorMonthHeaderItem(
    for month: Month,
    offset: CGPoint,
    scrollPosition: CalendarViewScrollPosition)
    -> LayoutItem
  {
    let baseMonthFrame = frameProvider.frameOfMonth(month, withOrigin: offset)
    let proposedMonthFrame = proposedScrollToItemFrame(
      fromBaseFrame: baseMonthFrame,
      for: scrollPosition,
      offset: offset)
    let proposedMonthHeaderFrame = frameProvider.frameOfMonthHeader(
      inMonthWithOrigin: proposedMonthFrame.origin)
    let finalMonthHeaderFrame = correctedScrollToItemFrameForContentBoundaries(
      fromProposedFrame: proposedMonthHeaderFrame,
      ofTargetInMonth: month,
      withFrame: proposedMonthFrame,
      bounds: CGRect(origin: offset, size: size))
    return LayoutItem(itemType: .monthHeader(month), frame: finalMonthHeaderFrame)
  }

  func anchorDayItem(
    for day: Day,
    offset: CGPoint,
    scrollPosition: CalendarViewScrollPosition)
    -> LayoutItem
  {
    let baseDayFrame = frameProvider.frameOfDay(day, inMonthWithOrigin: offset)
    let proposedDayFrame = proposedScrollToItemFrame(
      fromBaseFrame: baseDayFrame,
      for: scrollPosition,
      offset: offset)
    let proposedMonthOrigin = frameProvider.originOfMonth(
      containing: LayoutItem(itemType: .day(day), frame: proposedDayFrame))
    let proposedMonthFrame = frameProvider.frameOfMonth(day.month, withOrigin: proposedMonthOrigin)
    let finalDayFrame = correctedScrollToItemFrameForContentBoundaries(
      fromProposedFrame: proposedDayFrame,
      ofTargetInMonth: day.month,
      withFrame: proposedMonthFrame,
      bounds: CGRect(origin: offset, size: size))
    return LayoutItem(itemType: .day(day), frame: finalDayFrame)
  }
  
  // MARK: Private
  
  private func proposedScrollToItemFrame(
    fromBaseFrame frame: CGRect,
    for scrollPosition: CalendarViewScrollPosition,
    offset: CGPoint)
    -> CGRect
  {
    switch content.monthsLayout {
    case .vertical(let options):
      let additionalOffset = (options.pinDaysOfWeekToTop ? frameProvider.daySize.height : 0)
      let minY = offset.y + additionalOffset
      let maxY = offset.y + size.height
      let firstFullyVisibleY = minY
      let lastFullyVisibleY = maxY - frame.height
      let y: CGFloat
      switch scrollPosition {
      case .centered:
        y = minY + ((maxY - minY) / 2) - (frame.height / 2)
      case .firstFullyVisiblePosition(let padding):
        y = firstFullyVisibleY + padding
      case .lastFullyVisiblePosition(let padding):
        y = lastFullyVisibleY - padding
      }

      return CGRect(x: frame.minX, y: y, width: frame.width, height: frame.height)

    case .horizontal:
      let minX = offset.x
      let maxX = offset.x + size.width
      let firstFullyVisibleX = minX
      let lastFullyVisibleX = maxX - frame.width
      let x: CGFloat
      switch scrollPosition {
      case .centered:
        x = minX + ((maxX - minX) / 2) - (frame.width / 2)
      case .firstFullyVisiblePosition(let padding):
        x = firstFullyVisibleX + padding
      case .lastFullyVisiblePosition(let padding):
        x = lastFullyVisibleX - padding
      }

      return CGRect(x: x, y: frame.minY, width: frame.width, height: frame.height)
    }
  }
  
  /// This function takes a proposed frame for a target item toward which we're programmatically scrolling, and adjusts it so that it's a
  /// valid frame when the calendar is at rest / not being overscrolled.
  ///
  /// A concrete example of when we'd need this correction is when we scroll to the first visible month with a scroll position of
  /// `.centered` - the proposed frame would position the month in the middle of the bounds, even though that is not a valid resting
  /// position for that month. Keep in mind that the first month in the calendar is going to be adjacent with the top / leading edge,
  /// depending on whether the months layout is `.vertical` or `.horizontal`, respectively. This function recognizes that
  /// situation by looking to see if we're close to the beginning / end of the calendar's content, and determines a correct final frame for
  /// a programmatic scroll.
  private func correctedScrollToItemFrameForContentBoundaries(
    fromProposedFrame proposedFrame: CGRect,
    ofTargetInMonth month: Month,
    withFrame monthFrame: CGRect,
    bounds: CGRect)
    -> CGRect
  {
    var minimumScrollOffset: CGFloat?
    var maximumScrollOffset: CGFloat?

    var currentMonth = month
    var currentMonthFrame = monthFrame

    // Look backwards for boundary-determining months
    while
      bounds.contains(currentMonthFrame.origin.alignedToPixels(forScreenWithScale: scale)),
      minimumScrollOffset == nil
    {
      determineContentBoundariesIfNeeded(
        for: currentMonth,
        withFrame: currentMonthFrame,
        minimumScrollOffset: &minimumScrollOffset,
        maximumScrollOffset: &maximumScrollOffset)

      let previousMonth = calendar.month(byAddingMonths: -1, to: currentMonth)
      let previousMonthOrigin = frameProvider.originOfMonth(
        previousMonth,
        beforeMonthWithOrigin: currentMonthFrame.origin)
      let previousMonthFrame = frameProvider.frameOfMonth(
        previousMonth,
        withOrigin: previousMonthOrigin)

      currentMonth = previousMonth
      currentMonthFrame = previousMonthFrame
    }

    // Look forwards for boundary-determining months
    currentMonth = month
    currentMonthFrame = monthFrame
    while
      bounds.contains(
        CGPoint(x: currentMonthFrame.maxX - 1, y: currentMonthFrame.maxY - 1)
          .alignedToPixels(forScreenWithScale: scale)),
      maximumScrollOffset == nil
    {
      determineContentBoundariesIfNeeded(
        for: currentMonth,
        withFrame: currentMonthFrame,
        minimumScrollOffset: &minimumScrollOffset,
        maximumScrollOffset: &maximumScrollOffset)

      let nextMonth = calendar.month(byAddingMonths: 1, to: currentMonth)
      let nextMonthOrigin = frameProvider.originOfMonth(
        nextMonth,
        afterMonthWithOrigin: currentMonthFrame.origin)
      let nextMonthFrame = frameProvider.frameOfMonth(nextMonth, withOrigin: nextMonthOrigin)

      currentMonth = nextMonth
      currentMonthFrame = nextMonthFrame
    }

    // Adjust the proposed frame if we're near a boundary so that the final frame is valid
    switch content.monthsLayout {
    case .vertical:
      if let minimumScrollOffset = minimumScrollOffset, minimumScrollOffset > bounds.minY {
        return proposedFrame.applying(.init(translationX: 0, y: bounds.minY - minimumScrollOffset))
      } else if let maximumScrollOffset = maximumScrollOffset, maximumScrollOffset < bounds.maxY {
        return proposedFrame.applying(.init(translationX: 0, y: bounds.maxY - maximumScrollOffset))
      } else {
        return proposedFrame
      }

    case .horizontal:
      if let minimumScrollOffset = minimumScrollOffset, minimumScrollOffset > bounds.minX {
        return proposedFrame.applying(.init(translationX: bounds.minX - minimumScrollOffset, y: 0))
      } else if let maximumScrollOffset = maximumScrollOffset, maximumScrollOffset < bounds.maxX {
        return proposedFrame.applying(.init(translationX: bounds.maxX - maximumScrollOffset, y: 0))
      } else {
        return proposedFrame
      }
    }
  }
  
}
