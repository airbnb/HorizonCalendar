// Created by Bryan Keller on 12/15/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

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

// MARK: - SubviewInsertionIndexTrackerTests

final class SubviewInsertionIndexTrackerTests: XCTestCase {

  // MARK: Internal

  func testCorrectSubviewsOrderFewItems() throws {
    let itemTypesToInsert: [VisibleItem.ItemType] = [
      .pinnedDayOfWeek(.first),
      .pinnedDaysOfWeekRowSeparator,
      .pinnedDaysOfWeekRowBackground,
      .overlayItem(.monthHeader(monthContainingDate: Date())),
      .daysOfWeekRowSeparator(
        Month(era: 1, year: 2022, month: 1, isInGregorianCalendar: true)),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2022, month: 1, isInGregorianCalendar: true))),
      .dayRange(.init(containing: Date()...Date(), in: .current)),
    ]

    var itemTypes = [VisibleItem.ItemType]()
    for itemTypeToInsert in itemTypesToInsert {
      let insertionIndex = subviewInsertionIndexTracker.insertionIndex(
        forSubviewWithCorrespondingItemType: itemTypeToInsert)
      itemTypes.insert(itemTypeToInsert, at: insertionIndex)
    }

    XCTAssert(itemTypes == itemTypesToInsert.sorted(), "Incorrect subviews order.")
  }

  func testCorrectSubviewsOrderManyItems() throws {
    let itemTypesToInsert: [VisibleItem.ItemType] = [
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2022, month: 1, isInGregorianCalendar: true))),
      .dayRange(.init(containing: Date()...Date(), in: .current)),
      .dayRange(.init(containing: Date()...Date(), in: .current)),
      .dayRange(.init(containing: Date()...Date(), in: .current)),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2022, month: 2, isInGregorianCalendar: true))),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2022, month: 3, isInGregorianCalendar: true))),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2022, month: 4, isInGregorianCalendar: true))),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2022, month: 5, isInGregorianCalendar: true))),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2022, month: 6, isInGregorianCalendar: true))),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2022, month: 7, isInGregorianCalendar: true))),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2022, month: 8, isInGregorianCalendar: true))),
      .overlayItem(.monthHeader(monthContainingDate: Date())),
      .pinnedDaysOfWeekRowBackground,
      .dayRange(.init(containing: Date()...Date(), in: .current)),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2022, month: 9, isInGregorianCalendar: true))),
      .pinnedDayOfWeek(.first),
      .pinnedDayOfWeek(.second),
      .daysOfWeekRowSeparator(
        Month(era: 1, year: 2022, month: 1, isInGregorianCalendar: true)),
      .pinnedDayOfWeek(.third),
      .pinnedDaysOfWeekRowSeparator,
      .pinnedDayOfWeek(.fourth),
      .pinnedDayOfWeek(.fifth),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2022, month: 10, isInGregorianCalendar: true))),
      .pinnedDayOfWeek(.sixth),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2022, month: 11, isInGregorianCalendar: true))),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2022, month: 12, isInGregorianCalendar: true))),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2022, month: 1, isInGregorianCalendar: true))),
      .dayRange(.init(containing: Date()...Date(), in: .current)),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2023, month: 1, isInGregorianCalendar: true))),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2023, month: 2, isInGregorianCalendar: true))),
      .daysOfWeekRowSeparator(
        Month(era: 1, year: 2023, month: 1, isInGregorianCalendar: true)),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2023, month: 3, isInGregorianCalendar: true))),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2023, month: 4, isInGregorianCalendar: true))),
      .pinnedDayOfWeek(.last),
    ]

    var itemTypes = [VisibleItem.ItemType]()
    for itemTypeToInsert in itemTypesToInsert {
      let insertionIndex = subviewInsertionIndexTracker.insertionIndex(
        forSubviewWithCorrespondingItemType: itemTypeToInsert)
      itemTypes.insert(itemTypeToInsert, at: insertionIndex)
    }

    XCTAssert(itemTypes == itemTypesToInsert.sorted(), "Incorrect subviews order.")
  }

  // MARK: Private

  private let subviewInsertionIndexTracker = SubviewInsertionIndexTracker()

}

// MARK: - VisibleItem.ItemType + Comparable

extension VisibleItem.ItemType: Comparable {

  // MARK: Public

  public static func < (
    lhs: HorizonCalendar.VisibleItem.ItemType,
    rhs: HorizonCalendar.VisibleItem.ItemType)
    -> Bool
  {
    lhs.relativeDistanceFromBack < rhs.relativeDistanceFromBack
  }

  // MARK: Private

  private var relativeDistanceFromBack: Int {
    switch self {
    case .monthBackground: return 0
    case .dayBackground: return 1
    case .dayRange: return 2
    case .layoutItemType: return 3
    case .daysOfWeekRowSeparator: return 4
    case .overlayItem: return 5
    case .pinnedDaysOfWeekRowBackground: return 6
    case .pinnedDayOfWeek: return 7
    case .pinnedDaysOfWeekRowSeparator: return 8
    }
  }

}
