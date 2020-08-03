// Created by Bryan Keller on 2/6/20.
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

// MARK: - VisibleItemsProvider

/// Provides details about the current set of visible items.
final class VisibleItemsProvider {

  // MARK: Lifecycle

  init(
    calendar: Calendar,
    content: CalendarViewContent,
    size: CGSize,
    layoutMargins: NSDirectionalEdgeInsets,
    scale: CGFloat,
    monthHeaderHeight: CGFloat)
  {
    self.content = content
    layoutItemTypeEnumerator = LayoutItemTypeEnumerator(
      calendar: calendar,
      monthsLayout: content.monthsLayout,
      monthRange: content.monthRange,
      dayRange: content.dayRange)
    frameProvider = FrameProvider(
      content: content,
      size: size,
      layoutMargins: layoutMargins,
      scale: scale,
      monthHeaderHeight: monthHeaderHeight)
  }

  // MARK: Internal

  let content: CalendarViewContent

  var size: CGSize {
    frameProvider.size
  }

  var layoutMargins: NSDirectionalEdgeInsets {
    frameProvider.layoutMargins
  }

  var scale: CGFloat {
    frameProvider.scale
  }

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

  func detailsForVisibleItems(
    surroundingPreviouslyVisibleLayoutItem previouslyVisibleLayoutItem: LayoutItem,
    offset: CGPoint)
    -> VisibleItemsDetails
  {
    var visibleItems = Set<VisibleCalendarItem>()
    var centermostLayoutItem = previouslyVisibleLayoutItem
    var firstVisibleDay: Day?
    var lastVisibleDay: Day?
    var firstVisibleMonth: Month?
    var lastVisibleMonth: Month?
    var framesForVisibleMonths = [Month: CGRect]()
    var framesForVisibleDays = [Day: CGRect]()
    var minimumScrollOffset: CGFloat?
    var maximumScrollOffset: CGFloat?
    var heightOfPinnedContent = CGFloat(0)

    // Default the initial capacity to 100, which is approximately enough room for 3 months worth of
    // calendar items.
    var calendarItemCache = Dictionary<VisibleCalendarItem.ItemType, AnyCalendarItem>(
      minimumCapacity: previousCalendarItemCache?.capacity ?? 100)

    // `extendedBounds` is used to make sure that we're always laying out a continuous set of items,
    // even if the last anchor item is completely off screen.
    //
    // When scrolling at a normal speed, the `bounds` will intersect with the
    // `previouslyVisibleLayoutItem`. When scrolling extremely fast, however, it's possible for the
    // `bounds` to have moved far enough in one frame that `previouslyVisibleLayoutItem` does not
    // intersect with it.
    //
    // One can think of `extendedBounds`'s purpose as increasing the layout region to compensate
    // for extremely fast scrolling / large per-frame bounds differences.
    let bounds = CGRect(origin: offset, size: size)
    let minX = min(bounds.minX, previouslyVisibleLayoutItem.frame.minX)
    let minY = min(bounds.minY, previouslyVisibleLayoutItem.frame.minY)
    let maxX = max(bounds.maxX, previouslyVisibleLayoutItem.frame.maxX)
    let maxY = max(bounds.maxY, previouslyVisibleLayoutItem.frame.maxY)
    let extendedBounds = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)

    var handledDayRanges = Set<DayRange>()

    var originsForMonths = [Month: CGPoint]()
    var lastHandledLayoutItemEnumeratingBackwards = previouslyVisibleLayoutItem
    var lastHandledLayoutItemEnumeratingForwards = previouslyVisibleLayoutItem

    layoutItemTypeEnumerator.enumerateItemTypes(
      startingAt: previouslyVisibleLayoutItem.itemType,
      itemTypeHandlerLookingBackwards: { itemType, shouldStop in
        let layoutItem = self.layoutItem(
          for: itemType,
          lastHandledLayoutItem: lastHandledLayoutItemEnumeratingBackwards,
          originsForMonths: &originsForMonths)
        lastHandledLayoutItemEnumeratingBackwards = layoutItem

        handleLayoutItem(
          layoutItem,
          inBounds: bounds,
          extendedBounds: extendedBounds,
          isLookingBackwards: true,
          centermostLayoutItem: &centermostLayoutItem,
          firstVisibleDay: &firstVisibleDay,
          lastVisibleDay: &lastVisibleDay,
          firstVisibleMonth: &firstVisibleMonth,
          lastVisibleMonth: &lastVisibleMonth,
          framesForVisibleMonths: &framesForVisibleMonths,
          framesForVisibleDays: &framesForVisibleDays,
          minimumScrollOffset: &minimumScrollOffset,
          maximumScrollOffset: &maximumScrollOffset,
          visibleItems: &visibleItems,
          calendarItemCache: &calendarItemCache,
          originsForMonths: &originsForMonths,
          handledDayRanges: &handledDayRanges,
          shouldStop: &shouldStop)
      },
      itemTypeHandlerLookingForwards: { itemType, shouldStop in
        let layoutItem = self.layoutItem(
          for: itemType,
          lastHandledLayoutItem: lastHandledLayoutItemEnumeratingForwards,
          originsForMonths: &originsForMonths)
        lastHandledLayoutItemEnumeratingForwards = layoutItem

        handleLayoutItem(
          layoutItem,
          inBounds: bounds,
          extendedBounds: extendedBounds,
          isLookingBackwards: false,
          centermostLayoutItem: &centermostLayoutItem,
          firstVisibleDay: &firstVisibleDay,
          lastVisibleDay: &lastVisibleDay,
          firstVisibleMonth: &firstVisibleMonth,
          lastVisibleMonth: &lastVisibleMonth,
          framesForVisibleMonths: &framesForVisibleMonths,
          framesForVisibleDays: &framesForVisibleDays,
          minimumScrollOffset: &minimumScrollOffset,
          maximumScrollOffset: &maximumScrollOffset,
          visibleItems: &visibleItems,
          calendarItemCache: &calendarItemCache,
          originsForMonths: &originsForMonths,
          handledDayRanges: &handledDayRanges,
          shouldStop: &shouldStop)
      })

    // Handle pinned day-of-week layout items
    if case .vertical(let options) = content.monthsLayout, options.pinDaysOfWeekToTop {
      handlePinnedDaysOfWeekIfNeeded(
        yContentOffset: bounds.minY,
        calendarItemCache: &calendarItemCache,
        visibleItems: &visibleItems,
        heightOfPinnedContent: &heightOfPinnedContent)
    }

    let visibleDayRange: DayRange?
    if let firstVisibleDay = firstVisibleDay, let lastVisibleDay = lastVisibleDay {
      visibleDayRange = firstVisibleDay...lastVisibleDay
    } else {
      visibleDayRange = nil
    }

    let visibleMonthRange: MonthRange?
    if let firstVisibleMonth = firstVisibleMonth, let lastVisibleMonth = lastVisibleMonth {
      visibleMonthRange = firstVisibleMonth...lastVisibleMonth
    } else {
      visibleMonthRange = nil
    }

    // Handle overlay items
    handleOverlayItemsIfNeeded(
      bounds: bounds,
      framesForVisibleMonths: framesForVisibleMonths,
      framesForVisibleDays: framesForVisibleDays,
      visibleItems: &visibleItems)

    previousCalendarItemCache = calendarItemCache

    return VisibleItemsDetails(
      visibleItems: visibleItems,
      centermostLayoutItem: centermostLayoutItem,
      visibleDayRange: visibleDayRange,
      visibleMonthRange: visibleMonthRange,
      framesForVisibleMonths: framesForVisibleMonths,
      framesForVisibleDays: framesForVisibleDays,
      minimumScrollOffset: minimumScrollOffset,
      maximumScrollOffset: maximumScrollOffset,
      heightOfPinnedContent: heightOfPinnedContent)
  }

  func visibleItemsForAccessibilityElements(
    surroundingPreviouslyVisibleLayoutItem previouslyVisibleLayoutItem: LayoutItem,
    visibleMonthRange: MonthRange)
    -> [VisibleCalendarItem]
  {
    var visibleItems = [VisibleCalendarItem]()

    // Look behind / ahead by 1 month to ensure that users can navigate by heading, even if an
    // adjacent month header is off-screen.
    let lowerBoundMonth = calendar.month(byAddingMonths: -1, to: visibleMonthRange.lowerBound)
    let upperBoundMonth = calendar.month(byAddingMonths: 1, to: visibleMonthRange.upperBound)
    let monthRange = lowerBoundMonth...upperBoundMonth

    let handleItem: (LayoutItem, Bool, inout Bool) -> Void =
    { layoutItem, isLookingBackwards, shouldStop in
      let month: Month
      let calendarItem: AnyCalendarItem
      switch layoutItem.itemType {
      case .monthHeader(let _month):
        month = _month
        calendarItem = self.content.monthHeaderItemProvider(month)
      case .day(let day):
        month = day.month
        calendarItem = self.content.dayItemProvider(day)
      case .dayOfWeekInMonth:
        return
      }

      guard monthRange.contains(month) else {
        shouldStop = true
        return
      }

      let item = VisibleCalendarItem(
        calendarItem: calendarItem,
        itemType: .layoutItemType(layoutItem.itemType),
        frame: layoutItem.frame)
      if isLookingBackwards {
        visibleItems.insert(item, at: 0)
      } else {
        visibleItems.append(item)
      }
    }

    var originsForMonths = [Month: CGPoint]()
    var lastHandledLayoutItemEnumeratingBackwards = previouslyVisibleLayoutItem
    var lastHandledLayoutItemEnumeratingForwards = previouslyVisibleLayoutItem

    layoutItemTypeEnumerator.enumerateItemTypes(
      startingAt: previouslyVisibleLayoutItem.itemType,
      itemTypeHandlerLookingBackwards: { itemType, shouldStop in
        let layoutItem = self.layoutItem(
          for: itemType,
          lastHandledLayoutItem: lastHandledLayoutItemEnumeratingBackwards,
          originsForMonths: &originsForMonths)
        lastHandledLayoutItemEnumeratingBackwards = layoutItem

        handleItem(layoutItem, true, &shouldStop)
      },
      itemTypeHandlerLookingForwards: { itemType, shouldStop in
        let layoutItem = self.layoutItem(
          for: itemType,
          lastHandledLayoutItem: lastHandledLayoutItemEnumeratingForwards,
          originsForMonths: &originsForMonths)
        lastHandledLayoutItemEnumeratingForwards = layoutItem

        handleItem(layoutItem, false, &shouldStop)
      })

    return visibleItems
  }

  // MARK: Private

  private let layoutItemTypeEnumerator: LayoutItemTypeEnumerator
  private let frameProvider: FrameProvider

  private var previousCalendarItemCache: [VisibleCalendarItem.ItemType: AnyCalendarItem]?

  private var calendar: Calendar {
    content.calendar
  }

  // Returns the layout item closest to the center of `bounds`.
  private func centermostLayoutItem(
    comparing item: LayoutItem,
    to otherItem: LayoutItem,
    inBounds bounds: CGRect)
    -> LayoutItem
  {
    let itemMidpoint = CGPoint(x: item.frame.midX, y: item.frame.midY)
    let otherItemMidpoint = CGPoint(x: otherItem.frame.midX, y: otherItem.frame.midY)
    let boundsMidpoint = CGPoint(x: bounds.midX, y: bounds.midY)

    let itemDistance = itemMidpoint.distance(to: boundsMidpoint)
    let otherItemDistance = otherItemMidpoint.distance(to: boundsMidpoint)
    return itemDistance < otherItemDistance ? item : otherItem
  }

  private func monthOrigin(
    forMonthContaining layoutItem: LayoutItem,
    originsForMonths: inout [Month: CGPoint])
    -> CGPoint
  {
    let monthOrigin: CGPoint
    if let origin = originsForMonths[layoutItem.itemType.month] {
      monthOrigin = origin
    } else {
      monthOrigin = frameProvider.originOfMonth(containing: layoutItem)
    }

    originsForMonths[layoutItem.itemType.month] = monthOrigin

    return monthOrigin
  }

  private func monthOrigin(
    for itemType: LayoutItem.ItemType,
    lastHandledLayoutItem: LayoutItem,
    originsForMonths: inout [Month: CGPoint])
    -> CGPoint
  {
    // Cache the month origin for `lastHandledLayoutItem`, if necessary
    if originsForMonths[lastHandledLayoutItem.itemType.month] == nil {
      let monthOrigin = frameProvider.originOfMonth(containing: lastHandledLayoutItem)
      originsForMonths[lastHandledLayoutItem.itemType.month] = monthOrigin
    }

    // Get (and cache) the month origin for the current item
    let monthOrigin: CGPoint
    if let origin = originsForMonths[itemType.month] {
      monthOrigin = origin
    } else if
      itemType.month < lastHandledLayoutItem.itemType.month,
      let origin = originsForMonths[lastHandledLayoutItem.itemType.month]
    {
      monthOrigin = frameProvider.originOfMonth(itemType.month, beforeMonthWithOrigin: origin)
    } else if
      itemType.month > lastHandledLayoutItem.itemType.month,
      let origin = originsForMonths[lastHandledLayoutItem.itemType.month]
    {
      monthOrigin = frameProvider.originOfMonth(itemType.month, afterMonthWithOrigin: origin)
    } else {
      preconditionFailure("""
        Could not determine the origin of the month containing the layout item type \(itemType).
      """)
    }

    originsForMonths[itemType.month] = monthOrigin

    return monthOrigin
  }

  private func layoutItem(
    for itemType: LayoutItem.ItemType,
    lastHandledLayoutItem: LayoutItem,
    originsForMonths: inout [Month: CGPoint])
    -> LayoutItem
  {
    let monthOrigin = self.monthOrigin(
      for: itemType,
      lastHandledLayoutItem: lastHandledLayoutItem,
      originsForMonths: &originsForMonths)

    // Get the frame for the current item
    let frame: CGRect
    switch itemType {
    case .monthHeader:
      frame = frameProvider.frameOfMonthHeader(inMonthWithOrigin: monthOrigin)
    case .dayOfWeekInMonth(let position, _):
      frame = frameProvider.frameOfDayOfWeek(at: position, inMonthWithOrigin: monthOrigin)
    case .day(let day):
      // If we're laying out a day in the same month as a previously laid out day, we can use the
      // faster `frameOfDay(_:adjacentTo:withFrame:inMonthWithOrigin:)` function.
      if
        case .day(let lastHandledDay) = lastHandledLayoutItem.itemType,
        day.month == lastHandledDay.month,
        abs(day.day - lastHandledDay.day) == 1
      {
        frame = frameProvider.frameOfDay(
          day,
          adjacentTo: lastHandledDay,
          withFrame: lastHandledLayoutItem.frame,
          inMonthWithOrigin: monthOrigin)
      } else {
        frame = frameProvider.frameOfDay(day, inMonthWithOrigin: monthOrigin)
      }
    }

    return LayoutItem(itemType: itemType, frame: frame)
  }

  // Builds a `DayRangeLayoutContext` by getting frames for each day layout item in the prodvided
  // `dayRange`, using the provided `day` and `frame` as a starting point.
  private func dayRangeLayoutContext(
    for dayRange: DayRange,
    containing day: Day,
    withFrame frame: CGRect,
    originsForMonths: inout [Month: CGPoint])
    -> DayRangeLayoutContext
  {
    guard dayRange.contains(day) else {
      preconditionFailure("""
        Cannot create day range items if the provided `day` (\(day)) is not contained in `dayRange`
        (\(dayRange)).
      """)
    }

    var daysAndFrames = [(day: Day, frame: CGRect)]()
    var boundingUnionRectOfDayFrames = frame
    let handleItem: (LayoutItem, Bool, inout Bool) -> Void =
      { layoutItem, isLookingBackwards, shouldStop in
        guard case .day(let day) = layoutItem.itemType else { return }
        guard dayRange.contains(day) else {
          shouldStop = true
          return
        }

        let frame = layoutItem.frame
        if isLookingBackwards {
          daysAndFrames.insert((day, frame), at: 0)
        } else {
          daysAndFrames.append((day, frame))
        }

        boundingUnionRectOfDayFrames = boundingUnionRectOfDayFrames.union(frame)
      }

    let dayLayoutItem = LayoutItem(itemType: .day(day), frame: frame)

    var lastHandledLayoutItemEnumeratingBackwards = dayLayoutItem
    var lastHandledLayoutItemEnumeratingForwards = dayLayoutItem

    layoutItemTypeEnumerator.enumerateItemTypes(
      startingAt: dayLayoutItem.itemType,
      itemTypeHandlerLookingBackwards: { itemType, shouldStop in
        let layoutItem = self.layoutItem(
          for: itemType,
          lastHandledLayoutItem: lastHandledLayoutItemEnumeratingBackwards,
          originsForMonths: &originsForMonths)
        lastHandledLayoutItemEnumeratingBackwards = layoutItem

        handleItem(layoutItem, true, &shouldStop)
      },
      itemTypeHandlerLookingForwards: { itemType, shouldStop in
        let layoutItem = self.layoutItem(
          for: itemType,
          lastHandledLayoutItem: lastHandledLayoutItemEnumeratingForwards,
          originsForMonths: &originsForMonths)
        lastHandledLayoutItemEnumeratingForwards = layoutItem

        handleItem(layoutItem, false, &shouldStop)
      })

    let frameToBoundsTransform = CGAffineTransform(
      translationX: -boundingUnionRectOfDayFrames.minX,
      y: -boundingUnionRectOfDayFrames.minY)

    return DayRangeLayoutContext(
      daysAndFrames: daysAndFrames.map {
        (
          $0.day,
          $0.frame.applying(frameToBoundsTransform).alignedToPixels(forScreenWithScale: scale)
        )
      },
      boundingUnionRectOfDayFrames: boundingUnionRectOfDayFrames
        .applying(frameToBoundsTransform)
        .alignedToPixels(forScreenWithScale: scale),
      frame: boundingUnionRectOfDayFrames)
  }

  private func overlayLayoutContext(
    for overlaidItemLocation: CalendarViewContent.OverlaidItemLocation,
    inBounds bounds: CGRect,
    framesForVisibleMonths: [Month: CGRect],
    framesForVisibleDays: [Day: CGRect])
    -> CalendarViewContent.OverlayLayoutContext?
  {
    let itemFrame: CGRect
    switch overlaidItemLocation {
    case .monthHeader(let date):
      let month = calendar.month(containing: date)
      guard let monthFrame = framesForVisibleMonths[month] else { return nil }
      itemFrame = frameProvider.frameOfMonthHeader(inMonthWithOrigin: monthFrame.origin)

    case .day(let date):
      let day = calendar.day(containing: date)
      guard let dayFrame = framesForVisibleDays[day] else { return nil }
      itemFrame = dayFrame
    }

    return .init(
      overlaidItemLocation: overlaidItemLocation,
      overlaidItemFrame: CGRect(
        origin: CGPoint(x: itemFrame.minX - bounds.minX, y: itemFrame.minY - bounds.minY),
        size: itemFrame.size)
        .alignedToPixels(forScreenWithScale: scale),
      availableBounds: CGRect(origin: .zero, size: bounds.size))
  }

  // Handles a layout item by creating a visible calendar item and adding it to the `visibleItems`
  // set if it's in `bounds`. This function also handles any visible items associated with the
  // provided `layoutItem`. For example, an individual `day` layout item may also have an associated
  // selection layer visible item, or a day range visible item.
  private func handleLayoutItem(
    _ layoutItem: LayoutItem,
    inBounds bounds: CGRect,
    extendedBounds: CGRect,
    isLookingBackwards: Bool,
    centermostLayoutItem: inout LayoutItem,
    firstVisibleDay: inout Day?,
    lastVisibleDay: inout Day?,
    firstVisibleMonth: inout Month?,
    lastVisibleMonth: inout Month?,
    framesForVisibleMonths: inout [Month: CGRect],
    framesForVisibleDays: inout [Day: CGRect],
    minimumScrollOffset: inout CGFloat?,
    maximumScrollOffset: inout CGFloat?,
    visibleItems: inout Set<VisibleCalendarItem>,
    calendarItemCache: inout [VisibleCalendarItem.ItemType: AnyCalendarItem],
    originsForMonths: inout [Month: CGPoint],
    handledDayRanges: inout Set<DayRange>,
    shouldStop: inout Bool)
  {
    let month = layoutItem.itemType.month

    // Calculate the current month frame if it's not cached; it will be used in other calculations.
    let monthFrame: CGRect
    if let cachedMonthFrame = framesForVisibleMonths[month] {
      monthFrame = cachedMonthFrame
    } else {
      let monthOrigin = frameProvider.originOfMonth(containing: layoutItem)
      monthFrame = frameProvider.frameOfMonth(month, withOrigin: monthOrigin)
    }

    if
      layoutItem.frame.intersects(extendedBounds) ||
      (content.monthsLayout.isHorizontal && monthFrame.intersects(extendedBounds))
    {
      firstVisibleMonth = min(firstVisibleMonth ?? month, month)
      lastVisibleMonth = max(lastVisibleMonth ?? month, month)

      // Use the calculated month frame to determine content boundaries if needed.
      determineContentBoundariesIfNeeded(
        for: month,
        withFrame: monthFrame,
        minimumScrollOffset: &minimumScrollOffset,
        maximumScrollOffset: &maximumScrollOffset)

      // Handle items that actually intersect the visible bounds.
      if layoutItem.frame.intersects(bounds) {
        // Store the month frame from above in the `framesForVisibleMonths` now that we've
        // determined that it's visible.
        if framesForVisibleMonths[month] == nil {
          framesForVisibleMonths[month] = monthFrame
        }

        let itemType = VisibleCalendarItem.ItemType.layoutItemType(layoutItem.itemType)

        let calendarItem: AnyCalendarItem
        switch layoutItem.itemType {
        case .monthHeader(let month):
          calendarItem = calendarItemCache.value(
            for: itemType,
            missingValueProvider: {
              previousCalendarItemCache?[itemType]
                ?? content.monthHeaderItemProvider(month)
            })

          // Create a visible item for the separator view, if needed.
          if
            !content.monthsLayout.pinDaysOfWeekToTop,
            let separatorOptions = content.daysOfTheWeekRowSeparatorOptions
          {
            let separatorItemType = VisibleCalendarItem.ItemType.daysOfWeekRowSeparator(month)
            let separatorCalendarItem = calendarItemCache.value(
              for: separatorItemType,
              missingValueProvider: {
                previousCalendarItemCache?[separatorItemType] ??
                  CalendarItem<UIView, Month>(
                    viewModel: month,
                    styleID: "DaysOfTheWeekRowSeparator",
                    buildView: {
                      let view = UIView()
                      view.backgroundColor = separatorOptions.color
                      return view
                    },
                    updateViewModel: { _, _ in })
              })

            visibleItems.insert(
              VisibleCalendarItem(
                calendarItem: separatorCalendarItem,
                itemType: separatorItemType,
                frame: frameProvider.frameOfDaysOfWeekRowSeparator(
                  inMonthWithOrigin: monthFrame.origin,
                  separatorHeight: separatorOptions.height)))
          }

        case let .dayOfWeekInMonth(dayOfWeekPosition, month):
          calendarItem = calendarItemCache.value(
            for: itemType,
            missingValueProvider: {
              let weekdayIndex = calendar.weekdayIndex(for: dayOfWeekPosition)
              return previousCalendarItemCache?[itemType]
                ?? content.dayOfWeekItemProvider(month, weekdayIndex)
            })

        case .day(let day):
          calendarItem = calendarItemCache.value(
            for: itemType,
            missingValueProvider: {
              previousCalendarItemCache?[itemType]
                ?? content.dayItemProvider(day)
            })

          handleDayRangesContaining(
            day,
            withFrame: layoutItem.frame,
            inBounds: bounds,
            visibleItems: &visibleItems,
            handledDayRanges: &handledDayRanges,
            originsForMonths: &originsForMonths)

          // Take into account the pinned days of week header when determining the first visible day
          if
            !content.monthsLayout.pinDaysOfWeekToTop ||
            layoutItem.frame.maxY > (bounds.minY + frameProvider.daySize.height)
          {
            firstVisibleDay = min(firstVisibleDay ?? day, day)
          }
          lastVisibleDay = max(lastVisibleDay ?? day, day)

          if framesForVisibleDays[day] == nil {
            framesForVisibleDays[day] = layoutItem.frame
          }
        }

        let visibleItem = VisibleCalendarItem(
          calendarItem: calendarItem,
          itemType: .layoutItemType(layoutItem.itemType),
          frame: layoutItem.frame)
        visibleItems.insert(visibleItem)

        centermostLayoutItem = self.centermostLayoutItem(
          comparing: layoutItem,
          to: centermostLayoutItem,
          inBounds: bounds)
      }
    } else {
      shouldStop = true
    }
  }

  private func determineContentBoundariesIfNeeded(
    for month: Month,
    withFrame monthFrame: CGRect,
    minimumScrollOffset: inout CGFloat?,
    maximumScrollOffset: inout CGFloat?)
  {
    if month == content.dayRange.lowerBound.month {
      switch content.monthsLayout {
      case .vertical(let options):
        minimumScrollOffset = monthFrame.minY -
          (options.pinDaysOfWeekToTop ? frameProvider.daySize.height : 0) -
          layoutMargins.top
      case .horizontal:
        minimumScrollOffset = monthFrame.minX - layoutMargins.leading
      }
    }

    if month == content.dayRange.upperBound.month {
      switch content.monthsLayout {
      case .vertical:
        maximumScrollOffset = monthFrame.maxY + layoutMargins.bottom
      case .horizontal:
        maximumScrollOffset = monthFrame.maxX + layoutMargins.trailing
      }
    }
  }

  // Handles each unhandled day range containing the provided `day` from
  // `content.dayRangesWithCalendarItems`.
  private func handleDayRangesContaining(
    _ day: Day,
    withFrame frame: CGRect,
    inBounds bounds: CGRect,
    visibleItems: inout Set<VisibleCalendarItem>,
    handledDayRanges: inout Set<DayRange>,
    originsForMonths: inout [Month: CGPoint])
  {
    // Handle day ranges that start or end with the current day.
    for dayRange in content.dayRangesAndItemProvider?.dayRanges ?? [] {
      guard
        !handledDayRanges.contains(dayRange),
        dayRange.contains(day)
      else
      {
        continue
      }

      let layoutContext = dayRangeLayoutContext(
        for: dayRange,
        containing: day,
        withFrame: frame,
        originsForMonths: &originsForMonths)
      handleDayRange(dayRange, with: layoutContext, inBounds: bounds, visibleItems: &visibleItems)
      handledDayRanges.insert(dayRange)
    }
  }

  // Handles a day range item by creating a visible calendar item and adding it to the
  // `visibleItems` set.
  private func handleDayRange(
    _ dayRange: DayRange,
    with dayRangeLayoutContext: DayRangeLayoutContext,
    inBounds bounds: CGRect,
    visibleItems: inout Set<VisibleCalendarItem>)
  {
    guard let dayRangeItemProvider = content.dayRangesAndItemProvider?.dayRangeItemProvider else {
      preconditionFailure(
        "`content.dayRangesAndItemProvider` cannot be nil when handling a day range.")
    }

    let frame = dayRangeLayoutContext.frame
    let dayRangeLayoutContext = CalendarViewContent.DayRangeLayoutContext(
      daysAndFrames: dayRangeLayoutContext.daysAndFrames,
      boundingUnionRectOfDayFrames: dayRangeLayoutContext.boundingUnionRectOfDayFrames)

    visibleItems.insert(
      VisibleCalendarItem(
        calendarItem: dayRangeItemProvider(dayRangeLayoutContext) ,
        itemType: .dayRange(dayRange),
        frame: frame))
  }

  private func handlePinnedDaysOfWeekIfNeeded(
    yContentOffset: CGFloat,
    calendarItemCache: inout [VisibleCalendarItem.ItemType: AnyCalendarItem],
    visibleItems: inout Set<VisibleCalendarItem>,
    heightOfPinnedContent: inout CGFloat)
  {
    var hasUpdatesHeightOfPinnedContent = false
    for dayOfWeekPosition in DayOfWeekPosition.allCases {
      let itemType = VisibleCalendarItem.ItemType.pinnedDayOfWeek(dayOfWeekPosition)

      let frame = frameProvider.frameOfPinnedDayOfWeek(
        at: dayOfWeekPosition,
        yContentOffset: yContentOffset)
      visibleItems.insert(
        VisibleCalendarItem(
          calendarItem: calendarItemCache.value(
            for: itemType,
            missingValueProvider: {
              let weekdayIndex = calendar.weekdayIndex(for: dayOfWeekPosition)
              return previousCalendarItemCache?[itemType] ??
                content.dayOfWeekItemProvider(nil, weekdayIndex)
            }),
          itemType: itemType,
          frame: frame))

      if !hasUpdatesHeightOfPinnedContent {
        heightOfPinnedContent += frame.height
        hasUpdatesHeightOfPinnedContent = true
      }
    }

    // The pinned days-of-the-week row needs a background view to prevent gaps between individual
    // items as content is scrolled underneath.
    visibleItems.insert(
      VisibleCalendarItem(
        calendarItem: CalendarItem<UIView, Int>.init(
          viewModel: 0,
          styleID: "PinnedDaysOfTheWeekRowBackground",
          buildView: { [unowned self] in
            let view = UIView()
            view.backgroundColor = self.content.backgroundColor
            return view
          },
          updateViewModel: { _, _ in }),
        itemType: .pinnedDaysOfWeekRowBackground,
        frame: frameProvider.frameOfPinnedDaysOfWeekRowBackground(yContentOffset: yContentOffset)))

    // Create a visible item for the separator view, if needed.
    if let separatorOptions = content.daysOfTheWeekRowSeparatorOptions {
      let separatorItemType = VisibleCalendarItem.ItemType.pinnedDaysOfWeekRowSeparator
      let separatorCalendarItem = calendarItemCache.value(
        for: separatorItemType,
        missingValueProvider: {
          previousCalendarItemCache?[separatorItemType] ??
            CalendarItem<UIView, Int>(
              viewModel: 0,
              styleID: "PinnedDaysOfTheWeekRowSeparator",
              buildView: {
                let view = UIView()
                view.backgroundColor = separatorOptions.color
                return view
              },
              updateViewModel: { _, _ in })
        })

      visibleItems.insert(
        VisibleCalendarItem(
          calendarItem: separatorCalendarItem,
          itemType: separatorItemType,
          frame: frameProvider.frameOfPinnedDaysOfWeekRowSeparator(
            yContentOffset: yContentOffset,
            separatorHeight: separatorOptions.height)))
    }
  }

  private func handleOverlayItemsIfNeeded(
    bounds: CGRect,
    framesForVisibleMonths: [Month: CGRect],
    framesForVisibleDays: [Day: CGRect],
    visibleItems: inout Set<VisibleCalendarItem>)
  {
    guard
      let (overlaidItemLocations, itemProvider) = content.overlaidItemLocationsAndItemProvider
    else
    {
      return
    }

    for overlaidItemLocation in overlaidItemLocations {
      guard
        let layoutContext = overlayLayoutContext(
          for: overlaidItemLocation,
          inBounds: bounds,
          framesForVisibleMonths: framesForVisibleMonths,
          framesForVisibleDays: framesForVisibleDays)
      else
      {
        continue
      }

      visibleItems.insert(
        VisibleCalendarItem(
          calendarItem: itemProvider(layoutContext),
          itemType: .overlayItem(overlaidItemLocation),
          frame: bounds))
    }
  }

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

  /// This function takes a proposed frame for a target item toward which we're programmatically scrolling, and adjusts it such that it's a
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

// MARK: - VisibleItemsDetails

struct VisibleItemsDetails {
  let visibleItems: Set<VisibleCalendarItem>
  let centermostLayoutItem: LayoutItem
  let visibleDayRange: DayRange?
  let visibleMonthRange: MonthRange?
  let framesForVisibleMonths: [Month: CGRect]
  let framesForVisibleDays: [Day: CGRect]
  let minimumScrollOffset: CGFloat?
  let maximumScrollOffset: CGFloat?
  let heightOfPinnedContent: CGFloat
}

// MARK: - DayRangeLayoutContext

/// Similar to `CalendarViewContent.DayRangeLayoutContext`, but also includes the `frame` of the day range visible item.
private struct DayRangeLayoutContext {
  let daysAndFrames: [(day: Day, frame: CGRect)]
  let boundingUnionRectOfDayFrames: CGRect
  let frame: CGRect
}

// MARK: CGPoint Distance Extension

private extension CGPoint {

  func distance(to otherPoint: CGPoint) -> CGFloat {
    sqrt(pow(otherPoint.x - x, 2) + pow(otherPoint.y - y, 2))
  }

}
