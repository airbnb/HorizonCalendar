// Created by Bryan Keller on 4/4/20.
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

import XCTest
@testable import HorizonCalendar

// MARK: - LayoutItemTypeEnumeratorTests

final class LayoutItemTypeEnumeratorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    let lowerBoundMonth = Month(era: 1, year: 2020, month: 11, isInGregorianCalendar: true)
    let upperBoundMonth = Month(era: 1, year: 2021, month: 1, isInGregorianCalendar: true)
    let monthRange = lowerBoundMonth...upperBoundMonth

    let lowerBoundDay = Day(month: lowerBoundMonth, day: 12)
    let upperBoundDay = Day(month: upperBoundMonth, day: 20)
    let dayRange = lowerBoundDay...upperBoundDay

    verticalItemTypeEnumerator = LayoutItemTypeEnumerator(
      calendar: calendar,
      monthsLayout: .vertical(options: VerticalMonthsLayoutOptions()),
      monthRange: monthRange,
      dayRange: dayRange)
    verticalPinnedDaysOfWeekItemTypeEnumerator = LayoutItemTypeEnumerator(
      calendar: calendar,
      monthsLayout: .vertical(options: VerticalMonthsLayoutOptions(pinDaysOfWeekToTop: true)),
      monthRange: monthRange,
      dayRange: dayRange)
    horizontalItemTypeEnumerator = LayoutItemTypeEnumerator(
      calendar: calendar,
      monthsLayout: .horizontal(
        options: HorizontalMonthsLayoutOptions(maximumFullyVisibleMonths: 305 / 300)),
      monthRange: monthRange,
      dayRange: dayRange)

    expectedItemTypeStackBackwards = [
      .dayOfWeekInMonth(
        position: .last,
        month: Month(era: 1, year: 2020, month: 12, isInGregorianCalendar: true)),
      .dayOfWeekInMonth(
        position: .sixth, month: Month(era: 1, year: 2020, month: 12, isInGregorianCalendar: true)),
      .dayOfWeekInMonth(
        position: .fifth,
        month: Month(era: 1, year: 2020, month: 12, isInGregorianCalendar: true)),
      .dayOfWeekInMonth(
        position: .fourth,
        month: Month(era: 1, year: 2020, month: 12, isInGregorianCalendar: true)),
      .dayOfWeekInMonth(
        position: .third,
        month: Month(era: 1, year: 2020, month: 12, isInGregorianCalendar: true)),
      .dayOfWeekInMonth(
        position: .second,
        month: Month(era: 1, year: 2020, month: 12, isInGregorianCalendar: true)),
      .dayOfWeekInMonth(
        position: .first,
        month: Month(era: 1, year: 2020, month: 12, isInGregorianCalendar: true)),
      .monthHeader(Month(era: 1, year: 2020, month: 12, isInGregorianCalendar: true)),
      .day(calendar.day(byAddingDays: -1, to: startDay)),
      .day(calendar.day(byAddingDays: -2, to: startDay)),
      .day(calendar.day(byAddingDays: -3, to: startDay)),
      .day(calendar.day(byAddingDays: -4, to: startDay)),
      .day(calendar.day(byAddingDays: -5, to: startDay)),
      .day(calendar.day(byAddingDays: -6, to: startDay)),
      .day(calendar.day(byAddingDays: -7, to: startDay)),
      .day(calendar.day(byAddingDays: -8, to: startDay)),
      .day(calendar.day(byAddingDays: -9, to: startDay)),
      .day(calendar.day(byAddingDays: -10, to: startDay)),
      .day(calendar.day(byAddingDays: -11, to: startDay)),
      .day(calendar.day(byAddingDays: -12, to: startDay)),
      .day(calendar.day(byAddingDays: -13, to: startDay)),
      .day(calendar.day(byAddingDays: -14, to: startDay)),
      .day(calendar.day(byAddingDays: -15, to: startDay)),
      .day(calendar.day(byAddingDays: -16, to: startDay)),
      .day(calendar.day(byAddingDays: -17, to: startDay)),
      .day(calendar.day(byAddingDays: -18, to: startDay)),
      .day(calendar.day(byAddingDays: -19, to: startDay)),
    ]

    expectedItemTypeStackForwards = [
      .day(startDay),
      .day(calendar.day(byAddingDays: 1, to: startDay)),
      .day(calendar.day(byAddingDays: 2, to: startDay)),
      .day(calendar.day(byAddingDays: 3, to: startDay)),
      .day(calendar.day(byAddingDays: 4, to: startDay)),
      .day(calendar.day(byAddingDays: 5, to: startDay)),
      .day(calendar.day(byAddingDays: 6, to: startDay)),
      .day(calendar.day(byAddingDays: 7, to: startDay)),
      .day(calendar.day(byAddingDays: 8, to: startDay)),
      .day(calendar.day(byAddingDays: 9, to: startDay)),
      .day(calendar.day(byAddingDays: 10, to: startDay)),
      .day(calendar.day(byAddingDays: 11, to: startDay)),
      .day(calendar.day(byAddingDays: 12, to: startDay)),
      .day(calendar.day(byAddingDays: 13, to: startDay)),
      .day(calendar.day(byAddingDays: 14, to: startDay)),
      .day(calendar.day(byAddingDays: 15, to: startDay)),
      .day(calendar.day(byAddingDays: 16, to: startDay)),
      .day(calendar.day(byAddingDays: 17, to: startDay)),
      .day(calendar.day(byAddingDays: 18, to: startDay)),
      .day(calendar.day(byAddingDays: 19, to: startDay)),
      .day(calendar.day(byAddingDays: 20, to: startDay)),
      .day(calendar.day(byAddingDays: 21, to: startDay)),
      .day(calendar.day(byAddingDays: 22, to: startDay)),
      .day(calendar.day(byAddingDays: 23, to: startDay)),
      .day(calendar.day(byAddingDays: 24, to: startDay)),
      .day(calendar.day(byAddingDays: 25, to: startDay)),
      .day(calendar.day(byAddingDays: 26, to: startDay)),
      .day(calendar.day(byAddingDays: 27, to: startDay)),
      .day(calendar.day(byAddingDays: 28, to: startDay)),
      .day(calendar.day(byAddingDays: 29, to: startDay)),
      .day(calendar.day(byAddingDays: 30, to: startDay)),
      .monthHeader(Month(era: 1, year: 2021, month: 01, isInGregorianCalendar: true)),
      .dayOfWeekInMonth(
        position: .first,
        month: Month(era: 1, year: 2021, month: 01, isInGregorianCalendar: true)),
      .dayOfWeekInMonth(
        position: .second,
        month: Month(era: 1, year: 2021, month: 01, isInGregorianCalendar: true)),
      .dayOfWeekInMonth(
        position: .third,
        month: Month(era: 1, year: 2021, month: 01, isInGregorianCalendar: true)),
      .dayOfWeekInMonth(
        position: .fourth,
        month: Month(era: 1, year: 2021, month: 01, isInGregorianCalendar: true)),
      .dayOfWeekInMonth(
        position: .fifth,
        month: Month(era: 1, year: 2021, month: 01, isInGregorianCalendar: true)),
      .dayOfWeekInMonth(
        position: .sixth,
        month: Month(era: 1, year: 2021, month: 01, isInGregorianCalendar: true)),
      .dayOfWeekInMonth(
        position: .last,
        month: Month(era: 1, year: 2021, month: 01, isInGregorianCalendar: true)),
      .day(calendar.day(byAddingDays: 31, to: startDay)),
      .day(calendar.day(byAddingDays: 32, to: startDay)),
      .day(calendar.day(byAddingDays: 33, to: startDay)),
      .day(calendar.day(byAddingDays: 34, to: startDay)),
      .day(calendar.day(byAddingDays: 35, to: startDay)),
      .day(calendar.day(byAddingDays: 36, to: startDay)),
      .day(calendar.day(byAddingDays: 37, to: startDay)),
      .day(calendar.day(byAddingDays: 38, to: startDay)),
      .day(calendar.day(byAddingDays: 39, to: startDay)),
      .day(calendar.day(byAddingDays: 40, to: startDay)),
      .day(calendar.day(byAddingDays: 41, to: startDay)),
      .day(calendar.day(byAddingDays: 42, to: startDay)),
      .day(calendar.day(byAddingDays: 43, to: startDay)),
      .day(calendar.day(byAddingDays: 44, to: startDay)),
      .day(calendar.day(byAddingDays: 45, to: startDay)),
      .day(calendar.day(byAddingDays: 46, to: startDay)),
      .day(calendar.day(byAddingDays: 47, to: startDay)),
      .day(calendar.day(byAddingDays: 48, to: startDay)),
      .day(calendar.day(byAddingDays: 49, to: startDay)),
      .day(calendar.day(byAddingDays: 50, to: startDay)),
    ]
  }

  func testEnumeratingVerticalItems() {
    verticalItemTypeEnumerator.enumerateItemTypes(
      startingAt: .day(startDay),
      itemTypeHandlerLookingBackwards: { itemType, shouldStop in
        let expectedItemType = expectedItemTypeStackBackwards.remove(at: 0)
        XCTAssert(
          itemType == expectedItemType,
          "Unexpected item type encountered while enumerating.")

        shouldStop = expectedItemTypeStackBackwards.isEmpty
      },
      itemTypeHandlerLookingForwards: { itemType, shouldStop in
        let expectedItemType = expectedItemTypeStackForwards.remove(at: 0)
        XCTAssert(
          itemType == expectedItemType,
          "Unexpected item type encountered while enumerating.")

        shouldStop = expectedItemTypeStackForwards.isEmpty
      })
  }

  func testEnumeratingVerticalPinnedDaysOfWeekItemsBackwards() {
    verticalPinnedDaysOfWeekItemTypeEnumerator.enumerateItemTypes(
      startingAt: .day(startDay),
      itemTypeHandlerLookingBackwards: { itemType, shouldStop in
        var expectedItemType = expectedItemTypeStackBackwards.remove(at: 0)
        // Skip days of the week since they're pinned to the top / outside of individual months
        while case .dayOfWeekInMonth = expectedItemType {
          expectedItemType = expectedItemTypeStackBackwards.remove(at: 0)
        }

        XCTAssert(
          itemType == expectedItemType,
          "Unexpected item type encountered while enumerating.")

        shouldStop = expectedItemTypeStackBackwards.isEmpty
      },
      itemTypeHandlerLookingForwards: { itemType, shouldStop in
        var expectedItemType = expectedItemTypeStackForwards.remove(at: 0)
        // Skip days of the week since they're pinned to the top / outside of individual months
        while case .dayOfWeekInMonth = expectedItemType {
          expectedItemType = expectedItemTypeStackForwards.remove(at: 0)
        }

        XCTAssert(
          itemType == expectedItemType,
          "Unexpected item type encountered while enumerating.")

        shouldStop = expectedItemTypeStackForwards.isEmpty
      })
  }

  func testEnumeratingHorizontalItemsBackwards() {
    verticalItemTypeEnumerator.enumerateItemTypes(
      startingAt: .day(startDay),
      itemTypeHandlerLookingBackwards: { itemType, shouldStop in
        let expectedItemType = expectedItemTypeStackBackwards.remove(at: 0)
        XCTAssert(
          itemType == expectedItemType,
          "Unexpected item type encountered while enumerating.")

        shouldStop = expectedItemTypeStackBackwards.isEmpty
      },
      itemTypeHandlerLookingForwards: { itemType, shouldStop in
        let expectedItemType = expectedItemTypeStackForwards.remove(at: 0)
        XCTAssert(
          itemType == expectedItemType,
          "Unexpected item type encountered while enumerating.")

        shouldStop = expectedItemTypeStackForwards.isEmpty
      })
  }

  // MARK: Private

  private let calendar = Calendar(identifier: .gregorian)
  private let startDay = Day(
    month: Month(era: 1, year: 2020, month: 12, isInGregorianCalendar: true),
    day: 1)

  // swiftlint:disable implicitly_unwrapped_optional

  private var verticalItemTypeEnumerator: LayoutItemTypeEnumerator!
  private var verticalPinnedDaysOfWeekItemTypeEnumerator: LayoutItemTypeEnumerator!
  private var horizontalItemTypeEnumerator: LayoutItemTypeEnumerator!

  private var expectedItemTypeStackBackwards: [LayoutItem.ItemType]!
  private var expectedItemTypeStackForwards: [LayoutItem.ItemType]!

}
