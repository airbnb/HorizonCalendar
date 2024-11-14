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
    backgroundColor: UIColor?)
  {
    self.content = content
    self.backgroundColor = backgroundColor

    layoutItemTypeEnumerator = LayoutItemTypeEnumerator(
      calendar: calendar,
      monthsLayout: content.monthsLayout,
      monthRange: content.monthRange,
      dayRange: content.dayRange)

    frameProvider = FrameProvider(
      content: content,
      size: size,
      layoutMargins: layoutMargins,
      scale: scale)
  }

  // MARK: Internal

  let content: CalendarViewContent
  let backgroundColor: UIColor?

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
    let layoutItem = LayoutItem(itemType: .monthHeader(month), frame: .zero)
    var context = VisibleItemsContext(centermostLayoutItem: layoutItem, firstLayoutItem: layoutItem)
    let monthHeaderHeight = monthHeaderHeight(for: month, context: &context)

    let monthOrigin: CGPoint
    switch content.monthsLayout {
    case .vertical:
      monthOrigin = offset
    case .horizontal:
      monthOrigin = CGPoint(
        x: offset.x,
        y: size.height - frameProvider.maxMonthHeight(monthHeaderHeight: monthHeaderHeight))
    }

    let baseMonthFrame = frameProvider.frameOfMonth(
      month,
      withOrigin: monthOrigin,
      monthHeaderHeight: monthHeaderHeight)
    let proposedMonthFrame = frameProvider.frameOfItem(
      withOriginalFrame: baseMonthFrame,
      at: scrollPosition,
      offset: offset)
    let proposedMonthHeaderFrame = frameProvider.frameOfMonthHeader(
      inMonthWithOrigin: proposedMonthFrame.origin,
      monthHeaderHeight: monthHeaderHeight)
    let finalMonthHeaderFrame = correctedScrollToItemFrameForContentBoundaries(
      fromProposedFrame: proposedMonthHeaderFrame,
      ofTargetInMonth: month,
      withMonthFrame: proposedMonthFrame,
      monthHeaderHeight: monthHeaderHeight,
      bounds: CGRect(origin: offset, size: size),
      context: &context)

    return LayoutItem(itemType: .monthHeader(month), frame: finalMonthHeaderFrame)
  }

  func anchorDayItem(
    for day: Day,
    offset: CGPoint,
    scrollPosition: CalendarViewScrollPosition)
    -> LayoutItem
  {
    let layoutItem = LayoutItem(itemType: .day(day), frame: .zero)
    var context = VisibleItemsContext(centermostLayoutItem: layoutItem, firstLayoutItem: layoutItem)
    let month = day.month
    let monthHeaderHeight = monthHeaderHeight(for: month, context: &context)

    let monthOrigin: CGPoint
    switch content.monthsLayout {
    case .vertical:
      monthOrigin = offset
    case .horizontal:
      monthOrigin = CGPoint(
        x: offset.x,
        y: size.height - frameProvider.maxMonthHeight(monthHeaderHeight: monthHeaderHeight))
    }

    let baseDayFrame = frameProvider.frameOfDay(
      day,
      inMonthWithOrigin: monthOrigin,
      monthHeaderHeight: monthHeaderHeight)
    let proposedDayFrame = frameProvider.frameOfItem(
      withOriginalFrame: baseDayFrame,
      at: scrollPosition,
      offset: offset)
    let proposedMonthOrigin = frameProvider.originOfMonth(
      containing: LayoutItem(
        itemType: .day(day),
        frame: proposedDayFrame),
      monthHeaderHeight: monthHeaderHeight)
    let proposedMonthFrame = frameProvider.frameOfMonth(
      day.month,
      withOrigin: proposedMonthOrigin,
      monthHeaderHeight: monthHeaderHeight)
    let finalDayFrame = correctedScrollToItemFrameForContentBoundaries(
      fromProposedFrame: proposedDayFrame,
      ofTargetInMonth: day.month,
      withMonthFrame: proposedMonthFrame,
      monthHeaderHeight: monthHeaderHeight,
      bounds: CGRect(origin: offset, size: size),
      context: &context)
    return LayoutItem(itemType: .day(day), frame: finalDayFrame)
  }

  func detailsForVisibleItems(
    surroundingPreviouslyVisibleLayoutItem previouslyVisibleLayoutItem: LayoutItem,
    offset: CGPoint,
    extendLayoutRegion: Bool)
    -> VisibleItemsDetails
  {
    // Default the initial capacity to 100, which is approximately enough room for 3 months worth of
    // calendar item models.
    var context = VisibleItemsContext(
      centermostLayoutItem: previouslyVisibleLayoutItem,
      firstLayoutItem: previouslyVisibleLayoutItem,
      calendarItemModelCache: .init(
        minimumCapacity: previousCalendarItemModelCache?.capacity ?? 100))

    let bounds: CGRect
    if extendLayoutRegion {
      bounds = boundsForExtendedRegionUpdatePass(atOffset: offset)
    } else {
      bounds = CGRect(origin: offset, size: size)
    }

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
    let minX = min(bounds.minX, previouslyVisibleLayoutItem.frame.minX)
    let minY = min(bounds.minY, previouslyVisibleLayoutItem.frame.minY)
    let maxX = max(bounds.maxX, previouslyVisibleLayoutItem.frame.maxX)
    let maxY = max(bounds.maxY, previouslyVisibleLayoutItem.frame.maxY)
    let extendedBounds = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)

    // Creating a new starting layout item based on our previous visible layout item allows us to
    // ensure that the most up-to-date layout metrics (day aspect ratio, margins, etc) are taken
    // into account. If layout metrics were just updated, then our previously visible layout item
    // could still have old values, leading to a slightly incorrect layout.
    let startingLayoutItem = layoutItem(
      for: previouslyVisibleLayoutItem.itemType,
      lastHandledLayoutItem: previouslyVisibleLayoutItem,
      monthHeaderHeight: monthHeaderHeight(
        for: previouslyVisibleLayoutItem.itemType.month,
        context: &context),
      context: &context)

    var lastHandledLayoutItemEnumeratingBackwards = startingLayoutItem
    var lastHandledLayoutItemEnumeratingForwards = startingLayoutItem

    layoutItemTypeEnumerator.enumerateItemTypes(
      startingAt: previouslyVisibleLayoutItem.itemType,
      itemTypeHandlerLookingBackwards: { itemType, shouldStop in
        let monthHeaderHeight = monthHeaderHeight(for: itemType.month, context: &context)

        let layoutItem = self.layoutItem(
          for: itemType,
          lastHandledLayoutItem: lastHandledLayoutItemEnumeratingBackwards,
          monthHeaderHeight: monthHeaderHeight,
          context: &context)
        lastHandledLayoutItemEnumeratingBackwards = layoutItem

        handleLayoutItem(
          layoutItem,
          inBounds: bounds,
          extendedBounds: extendedBounds,
          isLookingBackwards: true,
          monthHeaderHeight: monthHeaderHeight,
          context: &context,
          shouldStop: &shouldStop)
      },
      itemTypeHandlerLookingForwards: { itemType, shouldStop in
        let monthHeaderHeight = monthHeaderHeight(for: itemType.month, context: &context)

        let layoutItem = self.layoutItem(
          for: itemType,
          lastHandledLayoutItem: lastHandledLayoutItemEnumeratingForwards,
          monthHeaderHeight: monthHeaderHeight,
          context: &context)
        lastHandledLayoutItemEnumeratingForwards = layoutItem

        handleLayoutItem(
          layoutItem,
          inBounds: bounds,
          extendedBounds: extendedBounds,
          isLookingBackwards: false,
          monthHeaderHeight: monthHeaderHeight,
          context: &context,
          shouldStop: &shouldStop)
      })

    // Handle pinned day-of-week layout items
    if case .vertical(let options) = content.monthsLayout, options.pinDaysOfWeekToTop {
      handlePinnedDaysOfWeekIfNeeded(yContentOffset: offset.y, context: &context)
    }

    let visibleDayRange: DayRange?
    if
      let firstVisibleDay = context.firstVisibleDay,
      let lastVisibleDay = context.lastVisibleDay
    {
      visibleDayRange = firstVisibleDay...lastVisibleDay
    } else {
      visibleDayRange = nil
    }

    let visibleMonthRange: MonthRange?
    if
      let firstVisibleMonth = context.firstVisibleMonth,
      let lastVisibleMonth = context.lastVisibleMonth
    {
      visibleMonthRange = firstVisibleMonth...lastVisibleMonth
    } else {
      visibleMonthRange = nil
    }

    // Handle overlay items
    handleOverlayItemsIfNeeded(bounds: bounds, context: &context)

    // Handle background items
    handleMonthBackgroundItemsIfNeeded(context: &context)

    previousHeightsForVisibleMonthHeaders = context.heightsForVisibleMonthHeaders
    previousCalendarItemModelCache = context.calendarItemModelCache

    return VisibleItemsDetails(
      visibleItems: context.visibleItems,
      centermostLayoutItem: context.centermostLayoutItem,
      firstLayoutItem: context.firstLayoutItem,
      visibleDayRange: visibleDayRange,
      visibleMonthRange: visibleMonthRange,
      framesForVisibleMonths: context.framesForVisibleMonths,
      framesForVisibleDays: context.framesForVisibleDays,
      contentStartBoundary: context.contentStartBoundary,
      contentEndBoundary: context.contentEndBoundary,
      heightOfPinnedContent: context.heightOfPinnedContent,
      maxMonthHeight: context.maxMonthHeight)
  }

  // MARK: Private

  private let layoutItemTypeEnumerator: LayoutItemTypeEnumerator
  private let frameProvider: FrameProvider

  private var sizingMonthHeaderViewsForViewDifferentiators = [
    _CalendarItemViewDifferentiator: UIView
  ]()
  private var previousHeightsForVisibleMonthHeaders: [Month: CGFloat]?
  private var previousCalendarItemModelCache: [VisibleItem.ItemType: AnyCalendarItemModel]?

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

  // Returns the layout item closest to the top/leading edge of `bounds`.
  private func firstLayoutItem(comparing item: LayoutItem, to otherItem: LayoutItem) -> LayoutItem {
    let itemOrigin: CGFloat
    let otherItemOrigin: CGFloat
    switch content.monthsLayout {
    case .vertical:
      itemOrigin = item.frame.minY
      otherItemOrigin = otherItem.frame.minY
    case .horizontal:
      itemOrigin = item.frame.minX
      otherItemOrigin = otherItem.frame.minX
    }

    return itemOrigin < otherItemOrigin ? item : otherItem
  }

  private func boundsForExtendedRegionUpdatePass(atOffset offset: CGPoint) -> CGRect {
    // Use a larger bounds (3x the viewport size) if we're in an animated update pass or voiceover
    // is on, reducing the likelihood of an item popping in / out or an accessibility element being
    // too far off screen to be focusable.
    let boundsMultiplier = CGFloat(3)
    switch content.monthsLayout {
    case .vertical:
      return CGRect(
        x: offset.x,
        y: offset.y - size.height,
        width: size.width,
        height: size.height * boundsMultiplier)

    case .horizontal:
      return CGRect(
        x: offset.x - size.width,
        y: offset.y,
        width: size.width * boundsMultiplier,
        height: size.height)
    }
  }

  private func monthOrigin(
    forMonthContaining layoutItem: LayoutItem,
    monthHeaderHeight: CGFloat,
    context: inout VisibleItemsContext)
    -> CGPoint
  {
    let monthOrigin: CGPoint
    if let origin = context.originsForMonths[layoutItem.itemType.month] {
      monthOrigin = origin
    } else {
      monthOrigin = frameProvider.originOfMonth(
        containing: layoutItem,
        monthHeaderHeight: monthHeaderHeight)
    }

    context.originsForMonths[layoutItem.itemType.month] = monthOrigin

    return monthOrigin
  }

  private func monthOrigin(
    for itemType: LayoutItem.ItemType,
    lastHandledLayoutItem: LayoutItem,
    monthHeaderHeight: CGFloat,
    context: inout VisibleItemsContext)
    -> CGPoint
  {
    // Cache the month origin for `lastHandledLayoutItem`, if necessary
    if context.originsForMonths[lastHandledLayoutItem.itemType.month] == nil {
      let monthOrigin = frameProvider.originOfMonth(
        containing: lastHandledLayoutItem,
        monthHeaderHeight: monthHeaderHeight)
      context.originsForMonths[lastHandledLayoutItem.itemType.month] = monthOrigin
    }

    // Get (and cache) the month origin for the current item
    let monthOrigin: CGPoint
    if let origin = context.originsForMonths[itemType.month] {
      monthOrigin = origin
    } else if
      itemType.month < lastHandledLayoutItem.itemType.month,
      let origin = context.originsForMonths[lastHandledLayoutItem.itemType.month]
    {
      let subsequentMonthHeaderHeight = self.monthHeaderHeight(
        for: lastHandledLayoutItem.itemType.month,
        context: &context)
      monthOrigin = frameProvider.originOfMonth(
        itemType.month,
        beforeMonthWithOrigin: origin,
        subsequentMonthHeaderHeight: subsequentMonthHeaderHeight,
        monthHeaderHeight: monthHeaderHeight)
    } else if
      itemType.month > lastHandledLayoutItem.itemType.month,
      let origin = context.originsForMonths[lastHandledLayoutItem.itemType.month]
    {
      let previousMonthHeaderHeight = self.monthHeaderHeight(
        for: lastHandledLayoutItem.itemType.month,
        context: &context)
      monthOrigin = frameProvider.originOfMonth(
        itemType.month,
        afterMonthWithOrigin: origin,
        previousMonthHeaderHeight: previousMonthHeaderHeight,
        monthHeaderHeight: monthHeaderHeight)
    } else {
      preconditionFailure("""
          Could not determine the origin of the month containing the layout item type \(itemType).
        """)
    }

    context.originsForMonths[itemType.month] = monthOrigin

    return monthOrigin
  }

  private func monthHeaderHeight(for month: Month, context: inout VisibleItemsContext) -> CGFloat {
    context.heightsForVisibleMonthHeaders.value(
      for: month,
      missingValueProvider: {
        previousHeightsForVisibleMonthHeaders?[month] ?? monthHeaderHeight(for: month)
      })
  }

  private func monthHeaderHeight(for month: Month) -> CGFloat {
    let monthHeaderItemModel = content.monthHeaderItemProvider(month)
    let monthHeaderView = sizingMonthHeaderViewsForViewDifferentiators.value(
      for: monthHeaderItemModel._itemViewDifferentiator,
      missingValueProvider: {
        monthHeaderItemModel._makeView()
      })
    monthHeaderItemModel._setContent(onViewOfSameType: monthHeaderView)

    let monthWidth: CGFloat
    switch content.monthsLayout {
    case .vertical:
      monthWidth = size.width
    case .horizontal(let options):
      monthWidth = options.monthWidth(
        calendarWidth: size.width,
        interMonthSpacing: content.interMonthSpacing)
    }

    let size = monthHeaderView.systemLayoutSizeFitting(
      CGSize(width: monthWidth, height: UIView.layoutFittingCompressedSize.height),
      withHorizontalFittingPriority: .required,
      verticalFittingPriority: .fittingSizeLevel)

    return size.height
  }

  private func layoutItem(
    for itemType: LayoutItem.ItemType,
    lastHandledLayoutItem: LayoutItem,
    monthHeaderHeight: CGFloat,
    context: inout VisibleItemsContext)
    -> LayoutItem
  {
    let monthOrigin = monthOrigin(
      for: itemType,
      lastHandledLayoutItem: lastHandledLayoutItem,
      monthHeaderHeight: monthHeaderHeight,
      context: &context)

    // Get the frame for the current item
    let frame: CGRect
    switch itemType {
    case .monthHeader:
      frame = frameProvider.frameOfMonthHeader(
        inMonthWithOrigin: monthOrigin,
        monthHeaderHeight: monthHeaderHeight)
    case .dayOfWeekInMonth(let position, _):
      frame = frameProvider.frameOfDayOfWeek(
        at: position,
        inMonthWithOrigin: monthOrigin,
        monthHeaderHeight: monthHeaderHeight)
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
        frame = frameProvider.frameOfDay(
          day,
          inMonthWithOrigin: monthOrigin,
          monthHeaderHeight: monthHeaderHeight)
      }
    }

    return LayoutItem(itemType: itemType, frame: frame)
  }

  // Builds a `_DayRangeLayoutContext` by getting frames for each day layout item in the provided
  // `dayRange`, using the provided `day` and `frame` as a starting point.
  private func dayRangeLayoutContext(
    for dayRange: DayRange,
    containing day: Day,
    withFrame frame: CGRect,
    context: inout VisibleItemsContext)
    -> _DayRangeLayoutContext
  {
    guard dayRange.contains(day) else {
      preconditionFailure("""
          Cannot create day range items if the provided `day` (\(day)) is not contained in `dayRange`
          (\(dayRange)).
        """)
    }

    var daysAndFrames = [(day: Day, frame: CGRect)]()
    var boundingUnionRectOfDayFrames = frame
    let handleItem: (LayoutItem, Bool, inout Bool) -> Void = { layoutItem, isLookingBackwards, shouldStop in
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
          monthHeaderHeight: monthHeaderHeight(for: itemType.month, context: &context),
          context: &context)
        lastHandledLayoutItemEnumeratingBackwards = layoutItem

        handleItem(layoutItem, true, &shouldStop)
      },
      itemTypeHandlerLookingForwards: { itemType, shouldStop in
        let layoutItem = self.layoutItem(
          for: itemType,
          lastHandledLayoutItem: lastHandledLayoutItemEnumeratingForwards,
          monthHeaderHeight: monthHeaderHeight(for: itemType.month, context: &context),
          context: &context)
        lastHandledLayoutItemEnumeratingForwards = layoutItem

        handleItem(layoutItem, false, &shouldStop)
      })

    let frameToBoundsTransform = CGAffineTransform(
      translationX: -boundingUnionRectOfDayFrames.minX,
      y: -boundingUnionRectOfDayFrames.minY)

    return _DayRangeLayoutContext(
      daysAndFrames: daysAndFrames.map {
        (
          $0.day,
          $0.frame.applying(frameToBoundsTransform).alignedToPixels(forScreenWithScale: scale))
      },
      boundingUnionRectOfDayFrames: boundingUnionRectOfDayFrames
        .applying(frameToBoundsTransform)
        .alignedToPixels(forScreenWithScale: scale),
      frame: boundingUnionRectOfDayFrames)
  }

  private func overlayLayoutContext(
    for overlaidItemLocation: OverlaidItemLocation,
    inBounds bounds: CGRect,
    context: inout VisibleItemsContext)
    -> OverlayLayoutContext?
  {
    let itemFrame: CGRect
    switch overlaidItemLocation {
    case .monthHeader(let date):
      let month = calendar.month(containing: date)
      guard let monthFrame = context.framesForVisibleMonths[month] else { return nil }

      let monthHeaderHeight = monthHeaderHeight(for: month, context: &context)

      itemFrame = frameProvider.frameOfMonthHeader(
        inMonthWithOrigin: monthFrame.origin,
        monthHeaderHeight: monthHeaderHeight)

    case .day(let date):
      let day = calendar.day(containing: date)
      guard let dayFrame = context.framesForVisibleDays[day] else { return nil }
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
  // day range or overlay visible item.
  private func handleLayoutItem(
    _ layoutItem: LayoutItem,
    inBounds bounds: CGRect,
    extendedBounds: CGRect,
    isLookingBackwards _: Bool,
    monthHeaderHeight: CGFloat,
    context: inout VisibleItemsContext,
    shouldStop: inout Bool)
  {
    let month = layoutItem.itemType.month

    // Calculate the current month frame if it's not cached; it will be used in other calculations.
    let monthFrame: CGRect
    if let cachedMonthFrame = context.framesForVisibleMonths[month] {
      monthFrame = cachedMonthFrame
    } else {
      let monthOrigin = frameProvider.originOfMonth(
        containing: layoutItem,
        monthHeaderHeight: monthHeaderHeight)
      monthFrame = frameProvider.frameOfMonth(
        month,
        withOrigin: monthOrigin,
        monthHeaderHeight: monthHeaderHeight)
    }

    context.maxMonthHeight = max(
      frameProvider.maxMonthHeight(monthHeaderHeight: monthHeaderHeight),
      context.maxMonthHeight)

    let layoutNonVisibleItemsInPartiallyVisibleMonth = content.monthsLayout.isHorizontal ||
      content.monthBackgroundItemProvider != nil

    if
      layoutItem.frame.intersects(extendedBounds) ||
      (layoutNonVisibleItemsInPartiallyVisibleMonth && monthFrame.intersects(extendedBounds))
    {
      context.firstVisibleMonth = min(context.firstVisibleMonth ?? month, month)
      context.lastVisibleMonth = max(context.lastVisibleMonth ?? month, month)

      // Use the calculated month frame to determine content boundaries if needed.
      determineContentBoundariesIfNeeded(for: month, withFrame: monthFrame, context: &context)

      if case .day(let day) = layoutItem.itemType {
        var framesForDaysInMonth = context.framesForDaysForVisibleMonths[month] ?? [:]
        framesForDaysInMonth[day] = layoutItem.frame
        context.framesForDaysForVisibleMonths[month] = framesForDaysInMonth
      }

      // Handle items that actually intersect the visible bounds.
      if layoutItem.frame.intersects(bounds) {
        // Store the month frame from above in the `framesForVisibleMonths` now that we've
        // determined that it's visible.
        if context.framesForVisibleMonths[month] == nil {
          context.framesForVisibleMonths[month] = monthFrame
        }

        let itemType = VisibleItem.ItemType.layoutItemType(layoutItem.itemType)

        let calendarItemModel: AnyCalendarItemModel
        switch layoutItem.itemType {
        case .monthHeader(let month):
          calendarItemModel = context.calendarItemModelCache.value(
            for: itemType,
            missingValueProvider: {
              previousCalendarItemModelCache?[itemType] ?? content.monthHeaderItemProvider(month)
            })

          // Create a visible item for the separator view, if needed.
          if
            !content.monthsLayout.pinDaysOfWeekToTop,
            let separatorOptions = content.daysOfTheWeekRowSeparatorOptions
          {
            let separatorItemType = VisibleItem.ItemType.daysOfWeekRowSeparator(month)
            let separatorCalendarItemModel = context.calendarItemModelCache.value(
              for: separatorItemType,
              missingValueProvider: {
                previousCalendarItemModelCache?[separatorItemType] ??
                  ColorViewRepresentable.calendarItemModel(
                    invariantViewProperties: separatorOptions.color)
              })

            context.visibleItems.insert(
              VisibleItem(
                calendarItemModel: separatorCalendarItemModel,
                itemType: separatorItemType,
                frame: frameProvider.frameOfDaysOfWeekRowSeparator(
                  inMonthWithOrigin: monthFrame.origin,
                  separatorHeight: separatorOptions.height,
                  monthHeaderHeight: monthHeaderHeight)))
          }

        case .dayOfWeekInMonth(let dayOfWeekPosition, let month):
          calendarItemModel = context.calendarItemModelCache.value(
            for: itemType,
            missingValueProvider: {
              let weekdayIndex = calendar.weekdayIndex(for: dayOfWeekPosition)
              return previousCalendarItemModelCache?[itemType]
                ?? content.dayOfWeekItemProvider(month, weekdayIndex)
            })

        case .day(let day):
          calendarItemModel = context.calendarItemModelCache.value(
            for: itemType,
            missingValueProvider: {
              previousCalendarItemModelCache?[itemType] ?? content.dayItemProvider(day)
            })

          // Handle the optional day background for this day
          let dayBackgroundItemModel = context.calendarItemModelCache.optionalValue(
            for: .dayBackground(day),
            missingValueProvider: {
              previousCalendarItemModelCache?[.dayBackground(day)]
                ?? content.dayBackgroundItemProvider?(day)
            })
          if let dayBackgroundItemModel {
            context.visibleItems.insert(
              VisibleItem(
                calendarItemModel: dayBackgroundItemModel,
                itemType: .dayBackground(day),
                frame: layoutItem.frame))
          }

          // Handle any day ranges that contain this day
          handleDayRangesContaining(
            day,
            withFrame: layoutItem.frame,
            inBounds: bounds,
            context: &context)

          // Take into account the pinned days of week header when determining the first visible day
          if
            !content.monthsLayout.pinDaysOfWeekToTop ||
            layoutItem.frame.maxY > (bounds.minY + frameProvider.dayOfWeekSize.height)
          {
            context.firstVisibleDay = min(context.firstVisibleDay ?? day, day)
          }
          context.lastVisibleDay = max(context.lastVisibleDay ?? day, day)

          if context.framesForVisibleDays[day] == nil {
            context.framesForVisibleDays[day] = layoutItem.frame
          }
        }

        let visibleItem = VisibleItem(
          calendarItemModel: calendarItemModel,
          itemType: .layoutItemType(layoutItem.itemType),
          frame: layoutItem.frame)
        context.visibleItems.insert(visibleItem)

        context.centermostLayoutItem = centermostLayoutItem(
          comparing: layoutItem,
          to: context.centermostLayoutItem,
          inBounds: bounds)

        context.firstLayoutItem = firstLayoutItem(
          comparing: layoutItem,
          to: context.firstLayoutItem)
      }
    } else {
      shouldStop = true
    }
  }

  private func determineContentBoundariesIfNeeded(
    for month: Month,
    withFrame monthFrame: CGRect,
    context: inout VisibleItemsContext)
  {
    if month == content.dayRange.lowerBound.month {
      switch content.monthsLayout {
      case .vertical(let options):
        context.contentStartBoundary = monthFrame.minY -
          (options.pinDaysOfWeekToTop ? frameProvider.dayOfWeekSize.height : 0)
      case .horizontal:
        context.contentStartBoundary = monthFrame.minX
      }
    }

    if month == content.dayRange.upperBound.month {
      switch content.monthsLayout {
      case .vertical:
        context.contentEndBoundary = monthFrame.maxY
      case .horizontal:
        context.contentEndBoundary = monthFrame.maxX
      }
    }
  }

  // Handles each unhandled day range containing the provided `day` from
  // `content.dayRangesWithCalendarItems`.
  private func handleDayRangesContaining(
    _ day: Day,
    withFrame frame: CGRect,
    inBounds bounds: CGRect,
    context: inout VisibleItemsContext)
  {
    // Handle day ranges that start or end with the current day.
    for dayRange in content.dayRangesAndItemProvider?.dayRanges ?? [] {
      guard
        !context.handledDayRanges.contains(dayRange),
        dayRange.contains(day)
      else {
        continue
      }

      let layoutContext = dayRangeLayoutContext(
        for: dayRange,
        containing: day,
        withFrame: frame,
        context: &context)
      handleDayRange(dayRange, with: layoutContext, inBounds: bounds, context: &context)
      context.handledDayRanges.insert(dayRange)
    }
  }

  // Handles a day range item by creating a visible calendar item and adding it to the
  // `visibleItems` set.
  private func handleDayRange(
    _ dayRange: DayRange,
    with dayRangeLayoutContext: _DayRangeLayoutContext,
    inBounds _: CGRect,
    context: inout VisibleItemsContext)
  {
    guard
      let dayRangeItemProvider = content.dayRangesAndItemProvider?.dayRangeItemProvider
    else {
      preconditionFailure(
        "`content.dayRangesAndItemProvider` cannot be nil when handling a day range.")
    }

    let frame = dayRangeLayoutContext.frame
    let dayRangeLayoutContext = DayRangeLayoutContext(
      dayRange: dayRange,
      daysAndFrames: dayRangeLayoutContext.daysAndFrames,
      boundingUnionRectOfDayFrames: dayRangeLayoutContext.boundingUnionRectOfDayFrames)

    let itemType = VisibleItem.ItemType.dayRange(dayRange)
    context.visibleItems.insert(
      VisibleItem(
        calendarItemModel: context.calendarItemModelCache.value(
          for: itemType,
          missingValueProvider: {
            previousCalendarItemModelCache?[itemType] ?? dayRangeItemProvider(dayRangeLayoutContext)
          }),
        itemType: itemType,
        frame: frame))
  }

  private func handlePinnedDaysOfWeekIfNeeded(
    yContentOffset: CGFloat,
    context: inout VisibleItemsContext)
  {
    var hasUpdatesHeightOfPinnedContent = false
    for dayOfWeekPosition in DayOfWeekPosition.allCases {
      let itemType = VisibleItem.ItemType.pinnedDayOfWeek(dayOfWeekPosition)

      let frame = frameProvider.frameOfPinnedDayOfWeek(
        at: dayOfWeekPosition,
        yContentOffset: yContentOffset)
      context.visibleItems.insert(
        VisibleItem(
          calendarItemModel: context.calendarItemModelCache.value(
            for: itemType,
            missingValueProvider: {
              let weekdayIndex = calendar.weekdayIndex(for: dayOfWeekPosition)
              return previousCalendarItemModelCache?[itemType] ??
                content.dayOfWeekItemProvider(nil, weekdayIndex)
            }),
          itemType: itemType,
          frame: frame))

      if !hasUpdatesHeightOfPinnedContent {
        context.heightOfPinnedContent += frame.height
        hasUpdatesHeightOfPinnedContent = true
      }
    }

    // The pinned days-of-the-week row needs a background view to prevent gaps between individual
    // items as content is scrolled underneath.
    context.visibleItems.insert(
      VisibleItem(
        calendarItemModel: ColorViewRepresentable.calendarItemModel(
          invariantViewProperties: backgroundColor ?? .clear),
        itemType: .pinnedDaysOfWeekRowBackground,
        frame: frameProvider.frameOfPinnedDaysOfWeekRowBackground(yContentOffset: yContentOffset)))

    // Create a visible item for the separator view, if needed.
    if let separatorOptions = content.daysOfTheWeekRowSeparatorOptions {
      let separatorItemType = VisibleItem.ItemType.pinnedDaysOfWeekRowSeparator
      let separatorCalendarItemModel = context.calendarItemModelCache.value(
        for: separatorItemType,
        missingValueProvider: {
          previousCalendarItemModelCache?[separatorItemType] ??
            ColorViewRepresentable.calendarItemModel(
              invariantViewProperties: separatorOptions.color)
        })

      context.visibleItems.insert(
        VisibleItem(
          calendarItemModel: separatorCalendarItemModel,
          itemType: separatorItemType,
          frame: frameProvider.frameOfPinnedDaysOfWeekRowSeparator(
            yContentOffset: yContentOffset,
            separatorHeight: separatorOptions.height)))
    }
  }

  private func handleOverlayItemsIfNeeded(bounds: CGRect, context: inout VisibleItemsContext) {
    guard
      let (overlaidItemLocations, itemModelProvider) = content.overlaidItemLocationsAndItemProvider
    else {
      return
    }

    for overlaidItemLocation in overlaidItemLocations {
      guard
        let layoutContext = overlayLayoutContext(
          for: overlaidItemLocation,
          inBounds: bounds,
          context: &context)
      else {
        continue
      }

      context.visibleItems.insert(
        VisibleItem(
          calendarItemModel: itemModelProvider(layoutContext),
          itemType: .overlayItem(overlaidItemLocation),
          frame: bounds))
    }
  }

  private func handleMonthBackgroundItemsIfNeeded(context: inout VisibleItemsContext) {
    guard let monthBackgroundItemProvider = content.monthBackgroundItemProvider else { return }

    for (month, monthFrame) in context.framesForVisibleMonths {
      guard let framesForDays = context.framesForDaysForVisibleMonths[month] else { continue }

      // We need to expand the frame of the month so that we have enough room at the edges to draw
      // the background without getting clipped.
      let extraWidth: CGFloat
      let extraHeight: CGFloat
      if content.monthsLayout.isHorizontal {
        extraWidth = content.interMonthSpacing // half before leading edge, half after trailing edge
        extraHeight = size.height - monthFrame.height
      } else {
        extraWidth = size.width - monthFrame.width
        extraHeight = content.interMonthSpacing // half before top edge, half after bottom edge
      }

      let expandedMonthFrame = CGRect(
        x: monthFrame.minX - (extraWidth / 2),
        y: monthFrame.minY - (extraHeight / 2),
        width: monthFrame.width + extraWidth,
        height: monthFrame.height + extraHeight)
      let frameToBoundsTransform = CGAffineTransform(
        translationX: -expandedMonthFrame.minX,
        y: -expandedMonthFrame.minY)

      let monthHeaderHeight = monthHeaderHeight(for: month, context: &context)

      // Get the month header frame
      let monthHeaderFrame = frameProvider.frameOfMonthHeader(
        inMonthWithOrigin: monthFrame.origin,
        monthHeaderHeight: monthHeaderHeight)
      let finalMonthHeaderFrame = monthHeaderFrame
        .applying(frameToBoundsTransform)
        .alignedToPixels(forScreenWithScale: scale)

      // Get the days-of-the-week item frames
      var dayOfWeekPositionsAndFrames = [(dayOfWeekPosition: DayOfWeekPosition, frame: CGRect)]()
      for dayOfWeekPosition in DayOfWeekPosition.allCases {
        let dayOfWeekFrame = frameProvider.frameOfDayOfWeek(
          at: dayOfWeekPosition,
          inMonthWithOrigin: monthFrame.origin,
          monthHeaderHeight: monthHeaderHeight)
        let finalDayOfWeekFrame = dayOfWeekFrame
          .applying(frameToBoundsTransform)
          .alignedToPixels(forScreenWithScale: scale)
        dayOfWeekPositionsAndFrames.append((dayOfWeekPosition, finalDayOfWeekFrame))
      }

      // Get all frames for days in the month
      var daysAndFrames = [(day: Day, frame: CGRect)]()
      for (day, dayFrame) in framesForDays {
        let finalDayFrame = dayFrame
          .applying(frameToBoundsTransform)
          .alignedToPixels(forScreenWithScale: scale)
        daysAndFrames.append((day, finalDayFrame))
      }

      let monthLayoutContext = MonthLayoutContext(
        month: month,
        monthHeaderFrame: finalMonthHeaderFrame,
        dayOfWeekPositionsAndFrames: dayOfWeekPositionsAndFrames,
        daysAndFrames: daysAndFrames.sorted(by: { $0.day < $1.day }),
        bounds: CGRect(origin: .zero, size: expandedMonthFrame.size))

      let itemType = VisibleItem.ItemType.monthBackground(month)
      let itemModel = context.calendarItemModelCache.optionalValue(
        for: itemType,
        missingValueProvider: {
          previousCalendarItemModelCache?[itemType] ??
            monthBackgroundItemProvider(monthLayoutContext)
        })
      if let itemModel {
        let visibleItem = VisibleItem(
          calendarItemModel: itemModel,
          itemType: itemType,
          frame: expandedMonthFrame)
        context.visibleItems.insert(visibleItem)
      }
    }
  }

  /// This function takes a proposed frame for a target item toward which we're programmatically scrolling, and adjusts it so that it's a
  /// valid frame when the calendar is at rest / not being over-scrolled.
  ///
  /// A concrete example of when we'd need this correction is when we scroll to the first visible month with a scroll position of
  /// `.centered` - the proposed frame would position the month in the middle of the bounds, even though that is not a valid resting
  /// position for that month. Keep in mind that the first month in the calendar is going to be adjacent with the top / leading edge,
  /// depending on whether the months layout is `.vertical` or `.horizontal`, respectively. This function recognizes that
  /// situation by looking to see if we're close to the beginning / end of the calendar's content, and determines a correct final frame.
  private func correctedScrollToItemFrameForContentBoundaries(
    fromProposedFrame proposedFrame: CGRect,
    ofTargetInMonth month: Month,
    withMonthFrame monthFrame: CGRect,
    monthHeaderHeight: CGFloat,
    bounds: CGRect,
    context: inout VisibleItemsContext)
    -> CGRect
  {
    var currentMonth = month
    var currentMonthFrame = monthFrame

    // Look backwards for boundary-determining months
    while
      bounds.intersects(currentMonthFrame.alignedToPixels(forScreenWithScale: scale)),
      context.contentStartBoundary == nil
    {
      determineContentBoundariesIfNeeded(
        for: currentMonth,
        withFrame: currentMonthFrame,
        context: &context)

      let previousMonth = calendar.month(byAddingMonths: -1, to: currentMonth)
      let previousMonthHeaderHeight = self.monthHeaderHeight(for: previousMonth, context: &context)
      let previousMonthOrigin = frameProvider.originOfMonth(
        previousMonth,
        beforeMonthWithOrigin: currentMonthFrame.origin,
        subsequentMonthHeaderHeight: monthHeaderHeight,
        monthHeaderHeight: monthHeaderHeight)
      let previousMonthFrame = frameProvider.frameOfMonth(
        previousMonth,
        withOrigin: previousMonthOrigin,
        monthHeaderHeight: previousMonthHeaderHeight)

      currentMonth = previousMonth
      currentMonthFrame = previousMonthFrame
    }

    // Look forwards for boundary-determining months
    currentMonth = month
    currentMonthFrame = monthFrame
    while
      bounds.intersects(currentMonthFrame.alignedToPixels(forScreenWithScale: scale)),
      context.contentEndBoundary == nil
    {
      determineContentBoundariesIfNeeded(
        for: currentMonth,
        withFrame: currentMonthFrame,
        context: &context)

      let nextMonth = calendar.month(byAddingMonths: 1, to: currentMonth)
      let nextMonthHeaderHeight = self.monthHeaderHeight(for: nextMonth, context: &context)
      let nextMonthOrigin = frameProvider.originOfMonth(
        nextMonth,
        afterMonthWithOrigin: currentMonthFrame.origin,
        previousMonthHeaderHeight: monthHeaderHeight,
        monthHeaderHeight: nextMonthHeaderHeight)
      let nextMonthFrame = frameProvider.frameOfMonth(
        nextMonth,
        withOrigin: nextMonthOrigin,
        monthHeaderHeight: monthHeaderHeight)

      currentMonth = nextMonth
      currentMonthFrame = nextMonthFrame
    }

    // Adjust the proposed frame if we're near a boundary so that the final frame is valid.
    switch content.monthsLayout {
    case .vertical:
      if
        let contentStartBoundary = context.contentStartBoundary,
        contentStartBoundary >= bounds.minY || context.contentEndBoundary != nil
      {
        // If the `maximumScrollOffset` is also non-nil, then we know the content is smaller than
        // `bounds.height` and can simply adjust based on the `minimumScrollOffset`.
        return proposedFrame.applying(
          .init(translationX: 0, y: bounds.minY - contentStartBoundary + layoutMargins.top))
      } else if
        let contentEndBoundary = context.contentEndBoundary,
        contentEndBoundary <= bounds.maxY
      {
        return proposedFrame.applying(
          .init(translationX: 0, y: bounds.maxY - contentEndBoundary - layoutMargins.bottom))
      } else {
        return proposedFrame
      }

    case .horizontal:
      if
        let contentStartBoundary = context.contentStartBoundary,
        contentStartBoundary >= bounds.minX || context.contentEndBoundary != nil
      {
        // If the `maximumScrollOffset` is also non-nil, then we know the content is smaller than
        // `bounds.width` and can simply adjust based on the `minimumScrollOffset`.
        return proposedFrame.applying(
          .init(translationX: bounds.minX - contentStartBoundary + layoutMargins.leading, y: 0))
      } else if
        let contentEndBoundary = context.contentEndBoundary,
        contentEndBoundary <= bounds.maxX
      {
        return proposedFrame.applying(
          .init(translationX: bounds.maxX - contentEndBoundary - layoutMargins.trailing, y: 0))
      } else {
        return proposedFrame
      }
    }
  }

}

// MARK: - VisibleItemsContext

private struct VisibleItemsContext {
  var centermostLayoutItem: LayoutItem
  var firstLayoutItem: LayoutItem
  var firstVisibleDay: Day?
  var lastVisibleDay: Day?
  var firstVisibleMonth: Month?
  var lastVisibleMonth: Month?
  var framesForVisibleMonths = [Month: CGRect]()
  var framesForVisibleDays = [Day: CGRect]()
  var framesForDaysForVisibleMonths = [Month: [Day: CGRect]]()
  var heightsForVisibleMonthHeaders = [Month: CGFloat]()
  var contentStartBoundary: CGFloat?
  var contentEndBoundary: CGFloat?
  var visibleItems = Set<VisibleItem>()
  var calendarItemModelCache = [VisibleItem.ItemType: AnyCalendarItemModel]()
  var originsForMonths = [Month: CGPoint]()
  var handledDayRanges = Set<DayRange>()
  var heightOfPinnedContent: CGFloat = 0
  var maxMonthHeight: CGFloat = 0
}

// MARK: - VisibleItemsDetails

struct VisibleItemsDetails {
  let visibleItems: Set<VisibleItem>
  let centermostLayoutItem: LayoutItem
  let firstLayoutItem: LayoutItem?
  let visibleDayRange: DayRange?
  let visibleMonthRange: MonthRange?
  let framesForVisibleMonths: [Month: CGRect]
  let framesForVisibleDays: [Day: CGRect]
  let contentStartBoundary: CGFloat?
  let contentEndBoundary: CGFloat?
  let heightOfPinnedContent: CGFloat
  let maxMonthHeight: CGFloat

  var intrinsicHeight: CGFloat {
    maxMonthHeight + heightOfPinnedContent
  }

}

// MARK: - _DayRangeLayoutContext

/// Similar to `DayRangeLayoutContext`, but also includes the `frame` of the day range visible item.
private struct _DayRangeLayoutContext {
  let daysAndFrames: [(day: Day, frame: CGRect)]
  let boundingUnionRectOfDayFrames: CGRect
  let frame: CGRect
}

// MARK: CGPoint Distance Extension

extension CGPoint {

  fileprivate func distance(to otherPoint: CGPoint) -> CGFloat {
    sqrt(pow(otherPoint.x - x, 2) + pow(otherPoint.y - y, 2))
  }

}
