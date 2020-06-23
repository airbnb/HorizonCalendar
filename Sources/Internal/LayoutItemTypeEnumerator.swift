// Created by Bryan Keller on 2/12/20.
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

// MARK: - LayoutItemTypeEnumerator

/// Facilitates the enumeration of layout item types adjacent to a starting layout item type. For example, month header -> weekday
/// header (x7) -> day (x31) -> month header (cont...). The core structure of the calendar (the ordering of it's core elements) is defined by
/// this class.
final class LayoutItemTypeEnumerator {

  // MARK: Lifecycle

  init(calendar: Calendar, monthsLayout: MonthsLayout, monthRange: MonthRange, dayRange: DayRange) {
    self.calendar = calendar
    self.monthsLayout = monthsLayout
    self.monthRange = monthRange
    self.dayRange = dayRange
  }

  // MARK: Internal

  func enumerateItemTypes(
    startingAt startingItemType: LayoutItem.ItemType,
    itemTypeHandlerLookingBackwards: (LayoutItem.ItemType, _ shouldStop: inout Bool) -> Void,
    itemTypeHandlerLookingForwards: (LayoutItem.ItemType, _ shouldStop: inout Bool) -> Void)
  {
    var currentItemType = previousItemType(from: startingItemType)

    var shouldStopLookingBackwards = false
    while !shouldStopLookingBackwards {
      guard isItemTypeInRange(currentItemType) else { break }
      itemTypeHandlerLookingBackwards(currentItemType, &shouldStopLookingBackwards)
      currentItemType = previousItemType(from: currentItemType)
    }

    currentItemType = startingItemType

    var shouldStopLookingForwards = false
    while !shouldStopLookingForwards {
      guard isItemTypeInRange(currentItemType) else { break }
      itemTypeHandlerLookingForwards(currentItemType, &shouldStopLookingForwards)
      currentItemType = nextItemType(from: currentItemType)
    }
  }

  // MARK: Private

  private let calendar: Calendar
  private let monthsLayout: MonthsLayout
  private let monthRange: MonthRange
  private let dayRange: DayRange

  private func isItemTypeInRange(_ itemType: LayoutItem.ItemType) -> Bool {
    switch itemType {
    case .monthHeader(let month):
      return monthRange.contains(month)
    case .dayOfWeekInMonth(_, let month):
      return monthRange.contains(month)
    case .day(let day):
      return dayRange.contains(day)
    }
  }

  private func previousItemType(from itemType: LayoutItem.ItemType) -> LayoutItem.ItemType {
    switch itemType {
    case .monthHeader(let month):
      let previousMonth = calendar.month(byAddingMonths: -1, to: month)
      let lastDateOfPreviousMonth = calendar.lastDate(of: previousMonth)
      return .day(calendar.day(containing: lastDateOfPreviousMonth))

    case let .dayOfWeekInMonth(position, month):
      if position == .first {
        return .monthHeader(month)
      } else {
        guard let previousPosition = DayOfWeekPosition(rawValue: position.rawValue - 1) else {
          preconditionFailure("Could not get the day-of-week position preceding \(position).")
        }
        return .dayOfWeekInMonth(position: previousPosition, month: month)
      }

    case .day(let day):
      if day.day == 1 || day == dayRange.lowerBound {
        if case .vertical(let options) = monthsLayout, options.pinDaysOfWeekToTop {
          return .monthHeader(day.month)
        } else {
          return .dayOfWeekInMonth(position: .last, month: day.month)
        }
      } else {
        return .day(calendar.day(byAddingDays: -1, to: day))
      }
    }
  }

  private func nextItemType(from itemType: LayoutItem.ItemType) -> LayoutItem.ItemType {
    switch itemType {
    case .monthHeader(let month):
      if case .vertical(let options) = monthsLayout, options.pinDaysOfWeekToTop {
        return .day(firstDayInRange(in: month))
      } else {
        return .dayOfWeekInMonth(position: .first, month: month)
      }

    case let .dayOfWeekInMonth(position, month):
      if position == .last {
        return .day(firstDayInRange(in: month))
      } else {
        guard let nextPosition = DayOfWeekPosition(rawValue: position.rawValue + 1) else {
          preconditionFailure("Could not get the day-of-week position succeeding \(position).")
        }
        return .dayOfWeekInMonth(position: nextPosition, month: month)
      }

    case .day(let day):
      let nextDay = calendar.day(byAddingDays: 1, to: day)
      if day.month != nextDay.month {
        return .monthHeader(nextDay.month)
      } else if day == dayRange.upperBound {
        let nextMonth = calendar.month(byAddingMonths: 1, to: nextDay.month)
        return .monthHeader(nextMonth)
      } else {
        return .day(nextDay)
      }
    }
  }

  private func firstDayInRange(in month: Month) -> Day {
    let firstDate = calendar.firstDate(of: month)
    let firstDay = calendar.day(containing: firstDate)

    if month == dayRange.lowerBound.month {
      return max(firstDay, dayRange.lowerBound)
    } else {
      return firstDay
    }
  }

}
