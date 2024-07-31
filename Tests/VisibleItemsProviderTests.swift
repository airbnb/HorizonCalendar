// Created by Bryan Keller on 4/5/20.
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

// MARK: - VisibleItemsProviderTests

/// To print out a set of expected item descriptions, copy and paste the output of:
/// `po print(details.visibleItems.map { "\"\($0.description)\",\n" }.sorted().joined())`
final class VisibleItemsProviderTests: XCTestCase {

  // MARK: Internal

  // MARK: Initial anchor layout item tests

  func testVerticalInitialVisibleMonthHeader() {
    let monthHeaderItem1 = verticalVisibleItemsProvider.anchorMonthHeaderItem(
      for: Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true),
      offset: CGPoint(x: 0, y: 100),
      scrollPosition: .firstFullyVisiblePosition)
    XCTAssert(
      monthHeaderItem1.description == "[itemType: .layoutItemType(.monthHeader(2020-01)), frame: (0.0, 100.0, 320.0, 50.0)]",
      "Unexpected initial month header item.")

    let monthHeaderItem2 = verticalVisibleItemsProvider.anchorMonthHeaderItem(
      for: Month(era: 1, year: 2020, month: 03, isInGregorianCalendar: true),
      offset: CGPoint(x: 0, y: 250),
      scrollPosition: .lastFullyVisiblePosition)
    XCTAssert(
      monthHeaderItem2.description == "[itemType: .layoutItemType(.monthHeader(2020-03)), frame: (0.0, 335.5, 320.0, 50.0)]",
      "Unexpected initial month header item.")

    let monthHeaderItem3 = verticalVisibleItemsProvider.anchorMonthHeaderItem(
      for: Month(era: 1, year: 2020, month: 06, isInGregorianCalendar: true),
      offset: CGPoint(x: 0, y: 400),
      scrollPosition: .centered)
    XCTAssert(
      monthHeaderItem3.description == "[itemType: .layoutItemType(.monthHeader(2020-06)), frame: (0.0, 443.0, 320.0, 50.0)]",
      "Unexpected initial month header item.")
  }

  func testVerticalPinnedDaysOfWeekInitialVisibleMonthHeader() {
    let monthHeaderItem1 = verticalPinnedDaysOfWeekVisibleItemsProvider.anchorMonthHeaderItem(
      for: Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true),
      offset: CGPoint(x: 0, y: 190),
      scrollPosition: .firstFullyVisiblePosition)
    XCTAssert(
      monthHeaderItem1.description == "[itemType: .layoutItemType(.monthHeader(2020-02)), frame: (0.0, 225.5, 320.0, 50.0)]",
      "Unexpected initial month header item.")

    let monthHeaderItem2 = verticalPinnedDaysOfWeekVisibleItemsProvider.anchorMonthHeaderItem(
      for: Month(era: 1, year: 2020, month: 03, isInGregorianCalendar: true),
      offset: CGPoint(x: 0, y: 200),
      scrollPosition: .lastFullyVisiblePosition)
    XCTAssert(
      monthHeaderItem2.description == "[itemType: .layoutItemType(.monthHeader(2020-03)), frame: (0.0, 341.5, 320.0, 50.0)]",
      "Unexpected initial month header item.")

    let monthHeaderItem3 = verticalPinnedDaysOfWeekVisibleItemsProvider.anchorMonthHeaderItem(
      for: Month(era: 1, year: 2020, month: 04, isInGregorianCalendar: true),
      offset: CGPoint(x: 0, y: 250),
      scrollPosition: .centered)
    XCTAssert(
      monthHeaderItem3.description == "[itemType: .layoutItemType(.monthHeader(2020-04)), frame: (0.0, 313.5, 320.0, 100.0)]",
      "Unexpected initial month header item.")
  }

  func testVerticalPartialMonthVisibleMonthHeader() {
    let monthHeaderItem1 = verticalPartialMonthVisibleItemsProvider.anchorMonthHeaderItem(
      for: Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true),
      offset: CGPoint(x: 0, y: 100),
      scrollPosition: .firstFullyVisiblePosition)
    XCTAssert(
      monthHeaderItem1.description == "[itemType: .layoutItemType(.monthHeader(2020-01)), frame: (0.0, 100.0, 320.0, 50.0)]",
      "Unexpected initial month header item.")

    let monthHeaderItem2 = verticalPartialMonthVisibleItemsProvider.anchorMonthHeaderItem(
      for: Month(era: 1, year: 2020, month: 03, isInGregorianCalendar: true),
      offset: CGPoint(x: 0, y: 250),
      scrollPosition: .lastFullyVisiblePosition)
    XCTAssert(
      monthHeaderItem2.description == "[itemType: .layoutItemType(.monthHeader(2020-03)), frame: (0.0, 335.5, 320.0, 50.0)]",
      "Unexpected initial month header item.")

    let monthHeaderItem3 = verticalPartialMonthVisibleItemsProvider.anchorMonthHeaderItem(
      for: Month(era: 1, year: 2020, month: 06, isInGregorianCalendar: true),
      offset: CGPoint(x: 0, y: 400),
      scrollPosition: .centered)
    XCTAssert(
      monthHeaderItem3.description == "[itemType: .layoutItemType(.monthHeader(2020-06)), frame: (0.0, 443.0, 320.0, 50.0)]",
      "Unexpected initial month header item.")
  }

  func testHorizontalInitialVisibleMonthHeader() {
    let monthHeaderItem1 = horizontalVisibleItemsProvider.anchorMonthHeaderItem(
      for: Month(era: 1, year: 2020, month: 11, isInGregorianCalendar: true),
      offset: CGPoint(x: 1000, y: 0),
      scrollPosition: .firstFullyVisiblePosition)
    XCTAssert(
      monthHeaderItem1.description == "[itemType: .layoutItemType(.monthHeader(2020-11)), frame: (1000.0, 50.0, 300.0, 50.0)]",
      "Unexpected initial month header item.")

    let monthHeaderItem2 = horizontalVisibleItemsProvider.anchorMonthHeaderItem(
      for: Month(era: 1, year: 2020, month: 09, isInGregorianCalendar: true),
      offset: CGPoint(x: 800, y: 0),
      scrollPosition: .lastFullyVisiblePosition)
    XCTAssert(
      monthHeaderItem2.description == "[itemType: .layoutItemType(.monthHeader(2020-09)), frame: (820.0, 50.0, 300.0, 50.0)]",
      "Unexpected initial month header item.")

    let monthHeaderItem3 = horizontalVisibleItemsProvider.anchorMonthHeaderItem(
      for: Month(era: 1, year: 2020, month: 10, isInGregorianCalendar: true),
      offset: CGPoint(x: 500, y: 0),
      scrollPosition: .centered)
    XCTAssert(
      monthHeaderItem3.description == "[itemType: .layoutItemType(.monthHeader(2020-10)), frame: (510.0, 50.0, 300.0, 50.0)]",
      "Unexpected initial month header item.")
  }

  func testVerticalInitialVisibleDay() {
    let day = Day(month: Month(era: 1, year: 2020, month: 04, isInGregorianCalendar: true), day: 20)

    let dayItem1 = verticalVisibleItemsProvider.anchorDayItem(
      for: day,
      offset: CGPoint(x: 0, y: 400),
      scrollPosition: .firstFullyVisiblePosition)
    XCTAssert(
      dayItem1.description == "[itemType: .layoutItemType(.day(2020-04-20)), frame: (50.5, 400.0, 35.5, 35.5)]",
      "Unexpected initial day item.")

    let dayItem2 = verticalVisibleItemsProvider.anchorDayItem(
      for: day,
      offset: CGPoint(x: 0, y: 200),
      scrollPosition: .lastFullyVisiblePosition)
    XCTAssert(
      dayItem2.description == "[itemType: .layoutItemType(.day(2020-04-20)), frame: (50.5, 644.5, 35.5, 35.5)]",
      "Unexpected initial day item.")

    let dayItem3 = verticalVisibleItemsProvider.anchorDayItem(
      for: day,
      offset: CGPoint(x: 0, y: 600),
      scrollPosition: .centered)
    XCTAssert(
      dayItem3.description == "[itemType: .layoutItemType(.day(2020-04-20)), frame: (50.5, 822.0, 35.5, 35.5)]",
      "Unexpected initial day item.")
  }

  func testInitialVisiblePositionsNeedingCorrection() {
    let dayItem1 = verticalVisibleItemsProvider.anchorDayItem(
      for: Day(month: Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true), day: 01),
      offset: CGPoint(x: 0, y: 400),
      scrollPosition: .lastFullyVisiblePosition)
    XCTAssert(
      dayItem1.description == "[itemType: .layoutItemType(.day(2020-01-01)), frame: (142.0, 535.5, 35.5, 35.5)]",
      "Unexpected initial day item.")

    let dayItem2 = verticalVisibleItemsProvider.anchorDayItem(
      for: Day(month: Month(era: 1, year: 2020, month: 12, isInGregorianCalendar: true), day: 31),
      offset: CGPoint(x: 0, y: 200),
      scrollPosition: .firstFullyVisiblePosition)
    XCTAssert(
      dayItem2.description == "[itemType: .layoutItemType(.day(2020-12-31)), frame: (188.0, 644.5, 35.5, 35.5)]",
      "Unexpected initial day item.")

    let dayItem3 = verticalPinnedDaysOfWeekVisibleItemsProvider.anchorDayItem(
      for: Day(month: Month(era: 1, year: 2020, month: 12, isInGregorianCalendar: true), day: 31),
      offset: CGPoint(x: 0, y: 200),
      scrollPosition: .centered)
    XCTAssert(
      dayItem3.description == "[itemType: .layoutItemType(.day(2020-12-31)), frame: (188.0, 644.5, 35.5, 35.5)]",
      "Unexpected initial day item.")

    let dayItem4 = horizontalVisibleItemsProvider.anchorDayItem(
      for: Day(month: Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true), day: 01),
      offset: CGPoint(x: 600, y: 0),
      scrollPosition: .lastFullyVisiblePosition)
    XCTAssert(
      dayItem4.description == "[itemType: .layoutItemType(.day(2020-01-01)), frame: (733.5, 183.0, 33.0, 33.0)]",
      "Unexpected initial day item.")

    let dayItem5 = horizontalVisibleItemsProvider.anchorDayItem(
      for: Day(month: Month(era: 1, year: 2020, month: 12, isInGregorianCalendar: true), day: 28),
      offset: CGPoint(x: 100, y: 0),
      scrollPosition: .firstFullyVisiblePosition)
    XCTAssert(
      dayItem5.description == "[itemType: .layoutItemType(.day(2020-12-28)), frame: (168.0, 394.5, 33.0, 33.0)]",
      "Unexpected initial day item.")
  }

  func testVerticalPinnedDaysOfWeekInitialVisibleDay() {
    let day = Day(month: Month(era: 1, year: 2020, month: 04, isInGregorianCalendar: true), day: 20)

    let dayItem1 = verticalPinnedDaysOfWeekVisibleItemsProvider.anchorDayItem(
      for: day,
      offset: CGPoint(x: 0, y: 0),
      scrollPosition: .firstFullyVisiblePosition)
    XCTAssert(
      dayItem1.description == "[itemType: .layoutItemType(.day(2020-04-20)), frame: (50.5, 35.5, 35.5, 35.5)]",
      "Unexpected initial day item.")

    let dayItem2 = verticalPinnedDaysOfWeekVisibleItemsProvider.anchorDayItem(
      for: day,
      offset: CGPoint(x: 0, y: 100),
      scrollPosition: .lastFullyVisiblePosition)
    XCTAssert(
      dayItem2.description == "[itemType: .layoutItemType(.day(2020-04-20)), frame: (50.5, 544.5, 35.5, 35.5)]",
      "Unexpected initial day item.")

    let dayItem3 = verticalPinnedDaysOfWeekVisibleItemsProvider.anchorDayItem(
      for: day,
      offset: CGPoint(x: 0, y: 1000),
      scrollPosition: .centered)
    XCTAssert(
      dayItem3.description == "[itemType: .layoutItemType(.day(2020-04-20)), frame: (50.5, 1240.0, 35.5, 35.5)]",
      "Unexpected initial day item.")
  }

  func testVerticalPartialMonthInitialVisibleDay() {
    let day = Day(month: Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true), day: 28)

    let dayItem1 = verticalPartialMonthVisibleItemsProvider.anchorDayItem(
      for: day,
      offset: CGPoint(x: 0, y: 400),
      scrollPosition: .firstFullyVisiblePosition)
    XCTAssert(
      dayItem1.description == "[itemType: .layoutItemType(.day(2020-01-28)), frame: (96.5, 400.0, 35.5, 35.5)]",
      "Unexpected initial day item.")

    let dayItem2 = verticalPartialMonthVisibleItemsProvider.anchorDayItem(
      for: day,
      offset: CGPoint(x: 0, y: 200),
      scrollPosition: .lastFullyVisiblePosition)
    XCTAssert(
      dayItem2.description == "[itemType: .layoutItemType(.day(2020-01-28)), frame: (96.5, 391.5, 35.5, 35.5)]",
      "Unexpected initial day item.")

    let dayItem3 = verticalPartialMonthVisibleItemsProvider.anchorDayItem(
      for: day,
      offset: CGPoint(x: 0, y: 600),
      scrollPosition: .centered)
    XCTAssert(
      dayItem3.description == "[itemType: .layoutItemType(.day(2020-01-28)), frame: (96.5, 791.5, 35.5, 35.5)]",
      "Unexpected initial day item.")
  }

  func testHorizontalInitialVisibleDay() {
    let day = Day(month: Month(era: 1, year: 2020, month: 04, isInGregorianCalendar: true), day: 20)

    let dayItem1 = horizontalVisibleItemsProvider.anchorDayItem(
      for: day,
      offset: CGPoint(x: 300, y: 0),
      scrollPosition: .firstFullyVisiblePosition)
    XCTAssert(
      dayItem1.description == "[itemType: .layoutItemType(.day(2020-04-20)), frame: (300.0, 341.5, 33.0, 33.0)]",
      "Unexpected initial day item.")

    let dayItem2 = horizontalVisibleItemsProvider.anchorDayItem(
      for: day,
      offset: CGPoint(x: 500, y: 0),
      scrollPosition: .lastFullyVisiblePosition)
    XCTAssert(
      dayItem2.description == "[itemType: .layoutItemType(.day(2020-04-20)), frame: (787.0, 341.5, 33.0, 33.0)]",
      "Unexpected initial day item.")

    let dayItem3 = horizontalVisibleItemsProvider.anchorDayItem(
      for: day,
      offset: CGPoint(x: 0, y: 0),
      scrollPosition: .centered)
    XCTAssert(
      dayItem3.description == "[itemType: .layoutItemType(.day(2020-04-20)), frame: (143.5, 341.5, 33.0, 33.0)]",
      "Unexpected initial day item.")
  }

  // MARK: Scrolled to middle of content tests

  func testVisibleItemsContextAfterMetricsChange() {
    let anchorLayoutItem = verticalVisibleItemsProvider.detailsForVisibleItems(
      surroundingPreviouslyVisibleLayoutItem: LayoutItem(
        itemType: .monthHeader(Month(era: 1, year: 2020, month: 03, isInGregorianCalendar: true)),
        frame: CGRect(x: 0, y: 200, width: 320, height: 50)),
      offset: CGPoint(x: 0, y: 150),
      extendLayoutRegion: false)
      .centermostLayoutItem
    let details = verticalShortDayAspectRatioVisibleItemsProvider.detailsForVisibleItems(
      surroundingPreviouslyVisibleLayoutItem: anchorLayoutItem,
      offset: CGPoint(x: 0, y: 150),
      extendLayoutRegion: false)

    let expectedVisibleItemDescriptions: Set<String> = [
      "[itemType: .dayBackground(2020-02-16), frame: (5.0, 165.0, 35.5, 18.0)]",
      "[itemType: .dayBackground(2020-02-17), frame: (50.5, 165.0, 35.5, 18.0)]",
      "[itemType: .dayBackground(2020-02-18), frame: (96.5, 165.0, 35.5, 18.0)]",
      "[itemType: .dayBackground(2020-02-19), frame: (142.0, 165.0, 35.5, 18.0)]",
      "[itemType: .dayBackground(2020-03-11), frame: (142.0, 391.5, 35.5, 18.0)]",
      "[itemType: .dayBackground(2020-03-12), frame: (188.0, 391.5, 35.5, 18.0)]",
      "[itemType: .dayBackground(2020-03-13), frame: (233.5, 391.5, 35.5, 18.0)]",
      "[itemType: .dayBackground(2020-03-14), frame: (279.5, 391.5, 35.5, 18.0)]",
      "[itemType: .dayBackground(2020-03-15), frame: (5.0, 429.5, 35.5, 18.0)]",
      "[itemType: .dayBackground(2020-03-16), frame: (50.5, 429.5, 35.5, 18.0)]",
      "[itemType: .dayBackground(2020-03-17), frame: (96.5, 429.5, 35.5, 18.0)]",
      "[itemType: .dayBackground(2020-03-18), frame: (142.0, 429.5, 35.5, 18.0)]",
      "[itemType: .dayBackground(2020-03-19), frame: (188.0, 429.5, 35.5, 18.0)]",
      "[itemType: .dayRange(2020-03-11, 2020-04-05), frame: (5.0, 391.5, 310.0, 370.0)]",
      "[itemType: .daysOfWeekRowSeparator(2020-3), frame: (-0.0, 332.5, 320.0, 1.0)]",
      "[itemType: .daysOfWeekRowSeparator(2020-4), frame: (0.0, 684.5, 320.0, 1.0)]",
      "[itemType: .layoutItemType(.day(2020-02-16)), frame: (5.0, 165.0, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-02-17)), frame: (50.5, 165.0, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-02-18)), frame: (96.5, 165.0, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-02-19)), frame: (142.0, 165.0, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-02-20)), frame: (188.0, 165.0, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-02-21)), frame: (233.5, 165.0, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-02-22)), frame: (279.5, 165.0, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-02-23)), frame: (5.0, 203.0, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-02-24)), frame: (50.5, 203.0, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-02-25)), frame: (96.5, 203.0, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-02-26)), frame: (142.0, 203.0, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-02-27)), frame: (188.0, 203.0, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-02-28)), frame: (233.5, 203.0, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-02-29)), frame: (279.5, 203.0, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-01)), frame: (5.0, 353.5, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-02)), frame: (50.5, 353.5, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-03)), frame: (96.5, 353.5, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-04)), frame: (142.0, 353.5, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-05)), frame: (188.0, 353.5, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-06)), frame: (233.5, 353.5, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-07)), frame: (279.5, 353.5, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-08)), frame: (5.0, 391.5, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-09)), frame: (50.5, 391.5, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-10)), frame: (96.5, 391.5, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-11)), frame: (142.0, 391.5, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-12)), frame: (188.0, 391.5, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-13)), frame: (233.5, 391.5, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-14)), frame: (279.5, 391.5, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-15)), frame: (5.0, 429.5, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-16)), frame: (50.5, 429.5, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-17)), frame: (96.5, 429.5, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-18)), frame: (142.0, 429.5, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-19)), frame: (188.0, 429.5, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-20)), frame: (233.5, 429.5, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-21)), frame: (279.5, 429.5, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-22)), frame: (5.0, 467.0, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-23)), frame: (50.5, 467.0, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-24)), frame: (96.5, 467.0, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-25)), frame: (142.0, 467.0, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-26)), frame: (188.0, 467.0, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-27)), frame: (233.5, 467.0, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-28)), frame: (279.5, 467.0, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-29)), frame: (5.0, 505.0, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-30)), frame: (50.5, 505.0, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.day(2020-03-31)), frame: (96.5, 505.0, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.fifth, 2020-03)), frame: (188.0, 315.5, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.first, 2020-03)), frame: (5.0, 315.5, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.fourth, 2020-03)), frame: (142.0, 315.5, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.last, 2020-03)), frame: (279.5, 315.5, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.second, 2020-03)), frame: (50.5, 315.5, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.sixth, 2020-03)), frame: (233.5, 315.5, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.third, 2020-03)), frame: (96.5, 315.5, 35.5, 18.0)]",
      "[itemType: .layoutItemType(.monthHeader(2020-03)), frame: (0.0, 235.5, 320.0, 50.0)]",
      "[itemType: .layoutItemType(.monthHeader(2020-04)), frame: (0.0, 538.0, 320.0, 100.0)]",
      "[itemType: .monthBackground(2020-02), frame: (0.0, -74.0, 320.0, 302.0)]",
      "[itemType: .monthBackground(2020-03), frame: (-0.0, 228.0, 320.0, 302.0)]",
      "[itemType: .monthBackground(2020-04), frame: (0.0, 530.5, 320.0, 352.0)]",
    ]

    XCTAssert(
      Set(details.visibleItems.map { $0.description }) == expectedVisibleItemDescriptions,
      "Unexpected visible items.")

    XCTAssert(
      details.centermostLayoutItem
        .description == "[itemType: .layoutItemType(.day(2020-03-11)), frame: (142.0, 391.5, 35.5, 18.0)]",
      "Unexpected centermost layout item.")
  }

  func testVerticalVisibleItemsContext() {
    let details = verticalVisibleItemsProvider.detailsForVisibleItems(
      surroundingPreviouslyVisibleLayoutItem: LayoutItem(
        itemType: .monthHeader(Month(era: 1, year: 2020, month: 03, isInGregorianCalendar: true)),
        frame: CGRect(x: 0, y: 200, width: 320, height: 50)),
      offset: CGPoint(x: 0, y: 150),
      extendLayoutRegion: false)

    let expectedVisibleItemDescriptions: Set<String> = [
      "[itemType: .dayBackground(2020-03-11), frame: (142.0, 391.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-03-12), frame: (188.0, 391.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-03-13), frame: (233.5, 391.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-03-14), frame: (279.5, 391.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-03-15), frame: (5.0, 447.0, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-03-16), frame: (50.5, 447.0, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-03-17), frame: (96.5, 447.0, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-03-18), frame: (142.0, 447.0, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-03-19), frame: (188.0, 447.0, 35.5, 35.5)]",
      "[itemType: .dayRange(2020-03-11, 2020-04-05), frame: (5.0, 391.5, 310.0, 495.0)]",
      "[itemType: .daysOfWeekRowSeparator(2020-3), frame: (0.0, 314.5, 320.0, 1.0)]",
      "[itemType: .daysOfWeekRowSeparator(2020-4), frame: (0.0, 774.0, 320.0, 1.0)]",
      "[itemType: .layoutItemType(.day(2020-02-23)), frame: (5.0, 149.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-02-24)), frame: (50.5, 149.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-02-25)), frame: (96.5, 149.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-02-26)), frame: (142.0, 149.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-02-27)), frame: (188.0, 149.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-02-28)), frame: (233.5, 149.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-02-29)), frame: (279.5, 149.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-01)), frame: (5.0, 335.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-02)), frame: (50.5, 335.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-03)), frame: (96.5, 335.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-04)), frame: (142.0, 335.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-05)), frame: (188.0, 335.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-06)), frame: (233.5, 335.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-07)), frame: (279.5, 335.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-08)), frame: (5.0, 391.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-09)), frame: (50.5, 391.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-10)), frame: (96.5, 391.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-11)), frame: (142.0, 391.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-12)), frame: (188.0, 391.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-13)), frame: (233.5, 391.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-14)), frame: (279.5, 391.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-15)), frame: (5.0, 447.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-16)), frame: (50.5, 447.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-17)), frame: (96.5, 447.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-18)), frame: (142.0, 447.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-19)), frame: (188.0, 447.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-20)), frame: (233.5, 447.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-21)), frame: (279.5, 447.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-22)), frame: (5.0, 503.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-23)), frame: (50.5, 503.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-24)), frame: (96.5, 503.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-25)), frame: (142.0, 503.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-26)), frame: (188.0, 503.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-27)), frame: (233.5, 503.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-28)), frame: (279.5, 503.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-29)), frame: (5.0, 558.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-30)), frame: (50.5, 558.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-03-31)), frame: (96.5, 558.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.fifth, 2020-03)), frame: (188.0, 280.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.first, 2020-03)), frame: (5.0, 280.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.fourth, 2020-03)), frame: (142.0, 280.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.last, 2020-03)), frame: (279.5, 280.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.second, 2020-03)), frame: (50.5, 280.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.sixth, 2020-03)), frame: (233.5, 280.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.third, 2020-03)), frame: (96.5, 280.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.monthHeader(2020-03)), frame: (0.0, 200.0, 320.0, 50.0)]",
      "[itemType: .layoutItemType(.monthHeader(2020-04)), frame: (0.0, 609.5, 320.0, 100.0)]",
      "[itemType: .monthBackground(2020-02), frame: (0.0, -217.0, 320.0, 409.5)]",
      "[itemType: .monthBackground(2020-03), frame: (0.0, 192.5, 320.0, 409.5)]",
      "[itemType: .monthBackground(2020-04), frame: (0.0, 602.0, 320.0, 459.5)]",
    ]

    XCTAssert(
      Set(details.visibleItems.map { $0.description }) == expectedVisibleItemDescriptions,
      "Unexpected visible items.")

    XCTAssert(
      details.centermostLayoutItem
        .description == "[itemType: .layoutItemType(.day(2020-03-11)), frame: (142.0, 391.5, 35.5, 35.5)]",
      "Unexpected centermost layout item.")

    XCTAssert(details.contentStartBoundary == nil, "Unexpected content start offset.")
    XCTAssert(details.contentEndBoundary == nil, "Unexpected content end offset.")
  }

  func testVerticalPinnedDaysOfWeekVisibleItemsContext() {
    let details = verticalPinnedDaysOfWeekVisibleItemsProvider.detailsForVisibleItems(
      surroundingPreviouslyVisibleLayoutItem: LayoutItem(
        itemType: .monthHeader(Month(era: 1, year: 2020, month: 06, isInGregorianCalendar: true)),
        frame: CGRect(x: 0, y: 450, width: 320, height: 40)),
      offset: CGPoint(x: 0, y: 450),
      extendLayoutRegion: false)

    let expectedVisibleItemDescriptions: Set<String> = [
      "[itemType: .dayBackground(2020-06-11), frame: (188.0, 585.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-06-12), frame: (233.5, 585.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-06-13), frame: (279.5, 585.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-06-14), frame: (5.0, 641.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-06-15), frame: (50.5, 641.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-06-16), frame: (96.5, 641.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-06-17), frame: (142.0, 641.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-06-18), frame: (188.0, 641.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-06-19), frame: (233.5, 641.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-01)), frame: (50.5, 530.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-02)), frame: (96.5, 530.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-03)), frame: (142.0, 530.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-04)), frame: (188.0, 530.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-05)), frame: (233.5, 530.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-06)), frame: (279.5, 530.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-07)), frame: (5.0, 585.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-08)), frame: (50.5, 585.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-09)), frame: (96.5, 585.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-10)), frame: (142.0, 585.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-11)), frame: (188.0, 585.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-12)), frame: (233.5, 585.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-13)), frame: (279.5, 585.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-14)), frame: (5.0, 641.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-15)), frame: (50.5, 641.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-16)), frame: (96.5, 641.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-17)), frame: (142.0, 641.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-18)), frame: (188.0, 641.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-19)), frame: (233.5, 641.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-20)), frame: (279.5, 641.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-21)), frame: (5.0, 697.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-22)), frame: (50.5, 697.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-23)), frame: (96.5, 697.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-24)), frame: (142.0, 697.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-25)), frame: (188.0, 697.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-26)), frame: (233.5, 697.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-27)), frame: (279.5, 697.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-28)), frame: (5.0, 753.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-29)), frame: (50.5, 753.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-30)), frame: (96.5, 753.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-01)), frame: (142.0, 883.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-02)), frame: (188.0, 883.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-03)), frame: (233.5, 883.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-04)), frame: (279.5, 883.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.monthHeader(2020-06)), frame: (0.0, 450.0, 320.0, 50.0)]",
      "[itemType: .layoutItemType(.monthHeader(2020-07)), frame: (0.0, 803.5, 320.0, 50.0)]",
      "[itemType: .monthBackground(2020-06), frame: (0.0, 442.5, 320.0, 353.5)]",
      "[itemType: .monthBackground(2020-07), frame: (0.0, 796.0, 320.0, 353.5)]",
      "[itemType: .pinnedDayOfWeek(.fifth), frame: (188.0, 450.0, 35.5, 35.5)]",
      "[itemType: .pinnedDayOfWeek(.first), frame: (5.0, 450.0, 35.5, 35.5)]",
      "[itemType: .pinnedDayOfWeek(.fourth), frame: (142.0, 450.0, 35.5, 35.5)]",
      "[itemType: .pinnedDayOfWeek(.last), frame: (279.5, 450.0, 35.5, 35.5)]",
      "[itemType: .pinnedDayOfWeek(.second), frame: (50.5, 450.0, 35.5, 35.5)]",
      "[itemType: .pinnedDayOfWeek(.sixth), frame: (233.5, 450.0, 35.5, 35.5)]",
      "[itemType: .pinnedDayOfWeek(.third), frame: (96.5, 450.0, 35.5, 35.5)]",
      "[itemType: .pinnedDaysOfWeekRowBackground, frame: (0.0, 450.0, 320.0, 35.5)]",
      "[itemType: .pinnedDaysOfWeekRowSeparator, frame: (0.0, 484.5, 320.0, 1.0)]",
    ]

    XCTAssert(
      Set(details.visibleItems.map { $0.description }) == expectedVisibleItemDescriptions,
      "Unexpected visible items.")

    XCTAssert(
      details.centermostLayoutItem
        .description == "[itemType: .layoutItemType(.day(2020-06-24)), frame: (142.0, 697.0, 35.5, 35.5)]",
      "Unexpected centermost layout item.")

    XCTAssert(details.contentStartBoundary == nil, "Unexpected content start offset.")
    XCTAssert(details.contentEndBoundary == nil, "Unexpected content end offset.")
  }

  func testVerticalPartialMonthVisibleItemsContext() {
    let details = verticalPartialMonthVisibleItemsProvider.detailsForVisibleItems(
      surroundingPreviouslyVisibleLayoutItem: LayoutItem(
        itemType: .monthHeader(Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true)),
        frame: CGRect(x: 0, y: 200, width: 320, height: 50)),
      offset: CGPoint(x: 0, y: 150),
      extendLayoutRegion: false)

    let expectedVisibleItemDescriptions: Set<String> = [
      "[itemType: .daysOfWeekRowSeparator(2020-1), frame: (0.0, 314.5, 320.0, 1.0)]",
      "[itemType: .daysOfWeekRowSeparator(2020-2), frame: (0.0, 557.0, 320.0, 1.0)]",
      "[itemType: .layoutItemType(.day(2020-01-25)), frame: (279.5, 335.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-26)), frame: (5.0, 391.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-27)), frame: (50.5, 391.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-28)), frame: (96.5, 391.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-29)), frame: (142.0, 391.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-30)), frame: (188.0, 391.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-31)), frame: (233.5, 391.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-02-01)), frame: (279.5, 578.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.fifth, 2020-01)), frame: (188.0, 280.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.fifth, 2020-02)), frame: (188.0, 522.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.first, 2020-01)), frame: (5.0, 280.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.first, 2020-02)), frame: (5.0, 522.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.fourth, 2020-01)), frame: (142.0, 280.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.fourth, 2020-02)), frame: (142.0, 522.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.last, 2020-01)), frame: (279.5, 280.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.last, 2020-02)), frame: (279.5, 522.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.second, 2020-01)), frame: (50.5, 280.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.second, 2020-02)), frame: (50.5, 522.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.sixth, 2020-01)), frame: (233.5, 280.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.sixth, 2020-02)), frame: (233.5, 522.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.third, 2020-01)), frame: (96.5, 280.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.third, 2020-02)), frame: (96.5, 522.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.monthHeader(2020-01)), frame: (0.0, 200.0, 320.0, 50.0)]",
      "[itemType: .layoutItemType(.monthHeader(2020-02)), frame: (0.0, 442.0, 320.0, 50.0)]",
      "[itemType: .monthBackground(2020-01), frame: (0.0, 192.5, 320.0, 242.0)]",
      "[itemType: .monthBackground(2020-02), frame: (0.0, 434.5, 320.0, 409.5)]",
    ]

    XCTAssert(
      Set(details.visibleItems.map { $0.description }) == expectedVisibleItemDescriptions,
      "Unexpected visible items.")

    XCTAssert(
      details.centermostLayoutItem
        .description == "[itemType: .layoutItemType(.day(2020-01-29)), frame: (142.0, 391.5, 35.5, 35.5)]",
      "Unexpected centermost layout item.")

    XCTAssert(details.contentStartBoundary == 200, "Unexpected content start offset.")
    XCTAssert(details.contentEndBoundary == nil, "Unexpected content end offset.")
  }

  func testHorizontalVisibleItemsContext() {
    let details = horizontalVisibleItemsProvider.detailsForVisibleItems(
      surroundingPreviouslyVisibleLayoutItem: LayoutItem(
        itemType: .monthHeader(Month(era: 1, year: 2020, month: 05, isInGregorianCalendar: true)),
        frame: CGRect(x: 250, y: 0, width: 300, height: 50)),
      offset: CGPoint(x: 100, y: 0),
      extendLayoutRegion: false)

    let expectedVisibleItemDescriptions: Set<String> = [
      "[itemType: .dayBackground(2020-04-11), frame: (197.0, 185.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-04-15), frame: (68.5, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-04-16), frame: (111.5, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-04-17), frame: (154.5, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-04-18), frame: (197.0, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-05-11), frame: (298.0, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-05-12), frame: (340.5, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-05-13), frame: (383.5, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-05-17), frame: (255.0, 291.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-05-18), frame: (298.0, 291.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-05-19), frame: (340.5, 291.5, 33.0, 33.0)]",
      "[itemType: .dayRange(2020-03-11, 2020-04-05), frame: (-375.0, 133.0, 605.0, 244.5)]",
      "[itemType: .dayRange(2020-04-30, 2020-05-14), frame: (111.5, 133.0, 433.5, 244.5)]",
      "[itemType: .daysOfWeekRowSeparator(2020-4), frame: (-65.0, 112.0, 300.0, 1.0)]",
      "[itemType: .daysOfWeekRowSeparator(2020-5), frame: (250.0, 112.0, 300.0, 1.0)]",
      "[itemType: .layoutItemType(.day(2020-04-01)), frame: (68.5, 133.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-02)), frame: (111.5, 133.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-03)), frame: (154.5, 133.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-04)), frame: (197.0, 133.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-08)), frame: (68.5, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-09)), frame: (111.5, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-10)), frame: (154.5, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-11)), frame: (197.0, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-15)), frame: (68.5, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-16)), frame: (111.5, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-17)), frame: (154.5, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-18)), frame: (197.0, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-22)), frame: (68.5, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-23)), frame: (111.5, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-24)), frame: (154.5, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-25)), frame: (197.0, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-29)), frame: (68.5, 344.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-30)), frame: (111.5, 344.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-03)), frame: (255.0, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-04)), frame: (298.0, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-05)), frame: (340.5, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-06)), frame: (383.5, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-10)), frame: (255.0, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-11)), frame: (298.0, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-12)), frame: (340.5, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-13)), frame: (383.5, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-17)), frame: (255.0, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-18)), frame: (298.0, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-19)), frame: (340.5, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-20)), frame: (383.5, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-24)), frame: (255.0, 344.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-25)), frame: (298.0, 344.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-26)), frame: (340.5, 344.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-27)), frame: (383.5, 344.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-31)), frame: (255.0, 397.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.fifth, 2020-04)), frame: (111.5, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.first, 2020-05)), frame: (255.0, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.fourth, 2020-04)), frame: (68.5, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.fourth, 2020-05)), frame: (383.5, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.last, 2020-04)), frame: (197.0, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.second, 2020-05)), frame: (298.0, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.sixth, 2020-04)), frame: (154.5, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.third, 2020-05)), frame: (340.5, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.monthHeader(2020-04)), frame: (-65.0, -50.0, 300.0, 100.0)]",
      "[itemType: .layoutItemType(.monthHeader(2020-05)), frame: (250.0, 0.0, 300.0, 50.0)]",
      "[itemType: .monthBackground(2020-04), frame: (-72.5, -76.5, 315.0, 480.0)]",
      "[itemType: .monthBackground(2020-05), frame: (242.5, -25.0, 315.0, 480.0)]",
    ]

    XCTAssert(
      Set(details.visibleItems.map { $0.description }) == expectedVisibleItemDescriptions,
      "Unexpected visible items.")

    XCTAssert(
      details.centermostLayoutItem
        .description == "[itemType: .layoutItemType(.day(2020-05-10)), frame: (255.0, 238.5, 33.0, 33.0)]",
      "Unexpected centermost layout item.")

    XCTAssert(details.contentStartBoundary == nil, "Unexpected content start offset.")
    XCTAssert(details.contentEndBoundary == nil, "Unexpected content end offset.")
  }

  func testLargeScrollOffsetSincePreviouslyVisibleItem() {
    let details = verticalVisibleItemsProvider.detailsForVisibleItems(
      surroundingPreviouslyVisibleLayoutItem: LayoutItem(
        itemType: .monthHeader(Month(era: 1, year: 2020, month: 12, isInGregorianCalendar: true)),
        frame: CGRect(x: 0, y: 3000, width: 320, height: 50)),
      offset: CGPoint(x: 0, y: 150),
      extendLayoutRegion: false)

    let expectedVisibleItemDescriptions: Set<String> = [
      "[itemType: .dayBackground(2020-05-11), frame: (50.5, 220.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-05-12), frame: (96.5, 220.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-05-13), frame: (142.0, 220.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-05-14), frame: (188.0, 220.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-05-15), frame: (233.5, 220.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-05-16), frame: (279.5, 220.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-05-17), frame: (5.0, 276.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-05-18), frame: (50.5, 276.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-05-19), frame: (96.5, 276.5, 35.5, 35.5)]",
      "[itemType: .dayRange(2020-04-30, 2020-05-14), frame: (5.0, -77.0, 310.0, 333.5)]",
      "[itemType: .daysOfWeekRowSeparator(2020-6), frame: (0.0, 553.5, 320.0, 1.0)]",
      "[itemType: .layoutItemType(.day(2020-05-03)), frame: (5.0, 165.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-04)), frame: (50.5, 165.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-05)), frame: (96.5, 165.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-06)), frame: (142.0, 165.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-07)), frame: (188.0, 165.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-08)), frame: (233.5, 165.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-09)), frame: (279.5, 165.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-10)), frame: (5.0, 220.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-11)), frame: (50.5, 220.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-12)), frame: (96.5, 220.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-13)), frame: (142.0, 220.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-14)), frame: (188.0, 220.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-15)), frame: (233.5, 220.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-16)), frame: (279.5, 220.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-17)), frame: (5.0, 276.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-18)), frame: (50.5, 276.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-19)), frame: (96.5, 276.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-20)), frame: (142.0, 276.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-21)), frame: (188.0, 276.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-22)), frame: (233.5, 276.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-23)), frame: (279.5, 276.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-24)), frame: (5.0, 332.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-25)), frame: (50.5, 332.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-26)), frame: (96.5, 332.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-27)), frame: (142.0, 332.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-28)), frame: (188.0, 332.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-29)), frame: (233.5, 332.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-30)), frame: (279.5, 332.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-31)), frame: (5.0, 388.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-01)), frame: (50.5, 574.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-02)), frame: (96.5, 574.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-03)), frame: (142.0, 574.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-04)), frame: (188.0, 574.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-05)), frame: (233.5, 574.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-06)), frame: (279.5, 574.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.fifth, 2020-06)), frame: (188.0, 518.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.first, 2020-06)), frame: (5.0, 518.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.fourth, 2020-06)), frame: (142.0, 518.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.last, 2020-06)), frame: (279.5, 518.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.second, 2020-06)), frame: (50.5, 518.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.sixth, 2020-06)), frame: (233.5, 518.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.third, 2020-06)), frame: (96.5, 518.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.monthHeader(2020-06)), frame: (0.0, 438.5, 320.0, 50.0)]",
      "[itemType: .monthBackground(2020-05), frame: (0.0, -34.0, 320.0, 465.0)]",
      "[itemType: .monthBackground(2020-06), frame: (0.0, 431.0, 320.0, 409.5)]",
    ]

    XCTAssert(
      Set(details.visibleItems.map { $0.description }) == expectedVisibleItemDescriptions,
      "Unexpected visible items.")

    XCTAssert(
      details.centermostLayoutItem
        .description == "[itemType: .layoutItemType(.day(2020-05-27)), frame: (142.0, 332.0, 35.5, 35.5)]",
      "Unexpected centermost layout item.")

    XCTAssert(details.contentStartBoundary == nil, "Unexpected content start offset.")
    XCTAssert(
      details.contentEndBoundary?.alignedToPixel(forScreenWithScale: 2) == 3444.5,
      "Unexpected content end offset.")
  }

  func testHorizontalLeadingMonthPartiallyClipped() {
    let details = horizontalVisibleItemsProvider.detailsForVisibleItems(
      surroundingPreviouslyVisibleLayoutItem: LayoutItem(
        itemType: .monthHeader(Month(era: 1, year: 2020, month: 2, isInGregorianCalendar: true)),
        frame: CGRect(x: 315, y: 0, width: 300, height: 50)),
      offset: CGPoint(x: 295, y: 0),
      extendLayoutRegion: false)

    let expectedVisibleItemDescriptions: Set<String> = [
      "[itemType: .dayBackground(2020-02-11), frame: (405.5, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-02-12), frame: (448.5, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-02-13), frame: (491.5, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-02-14), frame: (534.5, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-02-15), frame: (577.0, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-02-16), frame: (320.0, 291.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-02-17), frame: (363.0, 291.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-02-18), frame: (405.5, 291.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-02-19), frame: (448.5, 291.5, 33.0, 33.0)]",
      "[itemType: .daysOfWeekRowSeparator(2020-1), frame: (0.0, 112.0, 300.0, 1.0)]",
      "[itemType: .daysOfWeekRowSeparator(2020-2), frame: (315.0, 112.0, 300.0, 1.0)]",
      "[itemType: .layoutItemType(.day(2020-02-01)), frame: (577.0, 133.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-02-02)), frame: (320.0, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-02-03)), frame: (363.0, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-02-04)), frame: (405.5, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-02-05)), frame: (448.5, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-02-06)), frame: (491.5, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-02-07)), frame: (534.5, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-02-08)), frame: (577.0, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-02-09)), frame: (320.0, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-02-10)), frame: (363.0, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-02-11)), frame: (405.5, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-02-12)), frame: (448.5, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-02-13)), frame: (491.5, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-02-14)), frame: (534.5, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-02-15)), frame: (577.0, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-02-16)), frame: (320.0, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-02-17)), frame: (363.0, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-02-18)), frame: (405.5, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-02-19)), frame: (448.5, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-02-20)), frame: (491.5, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-02-21)), frame: (534.5, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-02-22)), frame: (577.0, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-02-23)), frame: (320.0, 344.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-02-24)), frame: (363.0, 344.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-02-25)), frame: (405.5, 344.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-02-26)), frame: (448.5, 344.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-02-27)), frame: (491.5, 344.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-02-28)), frame: (534.5, 344.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-02-29)), frame: (577.0, 344.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.fifth, 2020-02)), frame: (491.5, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.first, 2020-02)), frame: (320.0, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.fourth, 2020-02)), frame: (448.5, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.last, 2020-02)), frame: (577.0, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.second, 2020-02)), frame: (363.0, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.sixth, 2020-02)), frame: (534.5, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.third, 2020-02)), frame: (405.5, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.monthHeader(2020-01)), frame: (0.0, 0.0, 300.0, 50.0)]",
      "[itemType: .layoutItemType(.monthHeader(2020-02)), frame: (315.0, 0.0, 300.0, 50.0)]",
      "[itemType: .monthBackground(2020-01), frame: (-7.5, -51.5, 315.0, 480.0)]",
      "[itemType: .monthBackground(2020-02), frame: (307.5, -51.5, 315.0, 480.0)]",
    ]

    XCTAssert(
      Set(details.visibleItems.map { $0.description }) == expectedVisibleItemDescriptions,
      "Unexpected visible items.")
  }

  // MARK: Scrolled to content boundary tests

  func testBoundaryVerticalVisibleItemsContext() {
    let details = verticalVisibleItemsProvider.detailsForVisibleItems(
      surroundingPreviouslyVisibleLayoutItem: LayoutItem(
        itemType: .monthHeader(Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true)),
        frame: CGRect(x: 0, y: 0, width: 320, height: 50)),
      offset: CGPoint(x: 0, y: -50),
      extendLayoutRegion: false)

    let expectedVisibleItemDescriptions: Set<String> = [
      "[itemType: .dayBackground(2020-01-11), frame: (279.5, 191.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-01-12), frame: (5.0, 247.0, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-01-13), frame: (50.5, 247.0, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-01-14), frame: (96.5, 247.0, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-01-15), frame: (142.0, 247.0, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-01-16), frame: (188.0, 247.0, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-01-17), frame: (233.5, 247.0, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-01-18), frame: (279.5, 247.0, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-01-19), frame: (5.0, 303.0, 35.5, 35.5)]",
      "[itemType: .daysOfWeekRowSeparator(2020-1), frame: (0.0, 114.5, 320.0, 1.0)]",
      "[itemType: .daysOfWeekRowSeparator(2020-2), frame: (0.0, 524.0, 320.0, 1.0)]",
      "[itemType: .layoutItemType(.day(2020-01-01)), frame: (142.0, 135.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-02)), frame: (188.0, 135.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-03)), frame: (233.5, 135.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-04)), frame: (279.5, 135.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-05)), frame: (5.0, 191.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-06)), frame: (50.5, 191.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-07)), frame: (96.5, 191.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-08)), frame: (142.0, 191.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-09)), frame: (188.0, 191.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-10)), frame: (233.5, 191.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-11)), frame: (279.5, 191.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-12)), frame: (5.0, 247.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-13)), frame: (50.5, 247.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-14)), frame: (96.5, 247.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-15)), frame: (142.0, 247.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-16)), frame: (188.0, 247.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-17)), frame: (233.5, 247.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-18)), frame: (279.5, 247.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-19)), frame: (5.0, 303.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-20)), frame: (50.5, 303.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-21)), frame: (96.5, 303.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-22)), frame: (142.0, 303.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-23)), frame: (188.0, 303.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-24)), frame: (233.5, 303.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-25)), frame: (279.5, 303.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-26)), frame: (5.0, 358.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-27)), frame: (50.5, 358.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-28)), frame: (96.5, 358.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-29)), frame: (142.0, 358.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-30)), frame: (188.0, 358.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-31)), frame: (233.5, 358.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.fifth, 2020-01)), frame: (188.0, 80.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.first, 2020-01)), frame: (5.0, 80.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.fourth, 2020-01)), frame: (142.0, 80.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.last, 2020-01)), frame: (279.5, 80.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.second, 2020-01)), frame: (50.5, 80.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.sixth, 2020-01)), frame: (233.5, 80.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.third, 2020-01)), frame: (96.5, 80.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.monthHeader(2020-01)), frame: (0.0, 0.0, 320.0, 50.0)]",
      "[itemType: .layoutItemType(.monthHeader(2020-02)), frame: (0.0, 409.5, 320.0, 50.0)]",
      "[itemType: .monthBackground(2020-01), frame: (0.0, -7.5, 320.0, 409.5)]",
      "[itemType: .monthBackground(2020-02), frame: (0.0, 402.0, 320.0, 409.5)]",
      "[itemType: .overlayItem(.day(2020-1-19)), frame: (0.0, -50.0, 320.0, 480.0)]",
    ]

    XCTAssert(
      Set(details.visibleItems.map { $0.description }) == expectedVisibleItemDescriptions,
      "Unexpected visible items.")

    XCTAssert(
      details.centermostLayoutItem
        .description == "[itemType: .layoutItemType(.day(2020-01-08)), frame: (142.0, 191.5, 35.5, 35.5)]",
      "Unexpected centermost layout item.")

    XCTAssert(details.contentStartBoundary == 0, "Unexpected content start offset.")
    XCTAssert(details.contentEndBoundary == nil, "Unexpected content end offset.")
  }

  func testBoundaryVerticalPinnedDaysOfWeekVisibleItemsContext() {
    let details = verticalPinnedDaysOfWeekVisibleItemsProvider.detailsForVisibleItems(
      surroundingPreviouslyVisibleLayoutItem: LayoutItem(
        itemType: .monthHeader(Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true)),
        frame: CGRect(x: 0, y: 45, width: 320, height: 40)),
      offset: CGPoint(x: 0, y: 50),
      extendLayoutRegion: false)

    let expectedVisibleItemDescriptions: Set<String> = [
      "[itemType: .dayBackground(2020-01-11), frame: (279.5, 180.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-01-12), frame: (5.0, 236.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-01-13), frame: (50.5, 236.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-01-14), frame: (96.5, 236.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-01-15), frame: (142.0, 236.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-01-16), frame: (188.0, 236.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-01-17), frame: (233.5, 236.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-01-18), frame: (279.5, 236.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-01-19), frame: (5.0, 292.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-01)), frame: (142.0, 125.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-02)), frame: (188.0, 125.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-03)), frame: (233.5, 125.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-04)), frame: (279.5, 125.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-05)), frame: (5.0, 180.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-06)), frame: (50.5, 180.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-07)), frame: (96.5, 180.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-08)), frame: (142.0, 180.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-09)), frame: (188.0, 180.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-10)), frame: (233.5, 180.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-11)), frame: (279.5, 180.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-12)), frame: (5.0, 236.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-13)), frame: (50.5, 236.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-14)), frame: (96.5, 236.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-15)), frame: (142.0, 236.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-16)), frame: (188.0, 236.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-17)), frame: (233.5, 236.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-18)), frame: (279.5, 236.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-19)), frame: (5.0, 292.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-20)), frame: (50.5, 292.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-21)), frame: (96.5, 292.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-22)), frame: (142.0, 292.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-23)), frame: (188.0, 292.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-24)), frame: (233.5, 292.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-25)), frame: (279.5, 292.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-26)), frame: (5.0, 348.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-27)), frame: (50.5, 348.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-28)), frame: (96.5, 348.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-29)), frame: (142.0, 348.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-30)), frame: (188.0, 348.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-01-31)), frame: (233.5, 348.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-02-01)), frame: (279.5, 478.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.monthHeader(2020-01)), frame: (0.0, 45.0, 320.0, 50.0)]",
      "[itemType: .layoutItemType(.monthHeader(2020-02)), frame: (0.0, 398.5, 320.0, 50.0)]",
      "[itemType: .monthBackground(2020-01), frame: (0.0, 37.5, 320.0, 353.5)]",
      "[itemType: .monthBackground(2020-02), frame: (0.0, 391.0, 320.0, 353.5)]",
      "[itemType: .overlayItem(.day(2020-1-19)), frame: (0.0, 50.0, 320.0, 480.0)]",
      "[itemType: .pinnedDayOfWeek(.fifth), frame: (188.0, 50.0, 35.5, 35.5)]",
      "[itemType: .pinnedDayOfWeek(.first), frame: (5.0, 50.0, 35.5, 35.5)]",
      "[itemType: .pinnedDayOfWeek(.fourth), frame: (142.0, 50.0, 35.5, 35.5)]",
      "[itemType: .pinnedDayOfWeek(.last), frame: (279.5, 50.0, 35.5, 35.5)]",
      "[itemType: .pinnedDayOfWeek(.second), frame: (50.5, 50.0, 35.5, 35.5)]",
      "[itemType: .pinnedDayOfWeek(.sixth), frame: (233.5, 50.0, 35.5, 35.5)]",
      "[itemType: .pinnedDayOfWeek(.third), frame: (96.5, 50.0, 35.5, 35.5)]",
      "[itemType: .pinnedDaysOfWeekRowBackground, frame: (0.0, 50.0, 320.0, 35.5)]",
      "[itemType: .pinnedDaysOfWeekRowSeparator, frame: (0.0, 84.5, 320.0, 1.0)]",
    ]

    XCTAssert(
      Set(details.visibleItems.map { $0.description }) == expectedVisibleItemDescriptions,
      "Unexpected visible items.")

    XCTAssert(
      details.centermostLayoutItem
        .description == "[itemType: .layoutItemType(.day(2020-01-22)), frame: (142.0, 292.0, 35.5, 35.5)]",
      "Unexpected centermost layout item.")

    XCTAssert(
      details.contentStartBoundary?.alignedToPixel(forScreenWithScale: 2) == 9.5,
      "Unexpected content start offset.")
    XCTAssert(details.contentEndBoundary == nil, "Unexpected content end offset.")
  }

  func testBoundaryVerticalPartialMonthVisibleItemsContext() {
    let details = verticalPartialMonthVisibleItemsProvider.detailsForVisibleItems(
      surroundingPreviouslyVisibleLayoutItem: LayoutItem(
        itemType: .monthHeader(Month(era: 1, year: 2020, month: 12, isInGregorianCalendar: true)),
        frame: CGRect(x: 0, y: 690, width: 320, height: 50)),
      offset: CGPoint(x: 0, y: 690),
      extendLayoutRegion: false)

    let expectedVisibleItemDescriptions: Set<String> = [
      "[itemType: .daysOfWeekRowSeparator(2020-12), frame: (0.0, 854.5, 320.0, 1.0)]",
      "[itemType: .layoutItemType(.day(2020-12-01)), frame: (96.5, 875.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.fifth, 2020-12)), frame: (188.0, 820.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.first, 2020-12)), frame: (5.0, 820.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.fourth, 2020-12)), frame: (142.0, 820.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.last, 2020-12)), frame: (279.5, 820.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.second, 2020-12)), frame: (50.5, 820.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.sixth, 2020-12)), frame: (233.5, 820.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.third, 2020-12)), frame: (96.5, 820.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.monthHeader(2020-12)), frame: (0.0, 690.0, 320.0, 100.0)]",
      "[itemType: .monthBackground(2020-12), frame: (0.0, 682.5, 320.0, 236.5)]",
    ]

    XCTAssert(
      Set(details.visibleItems.map { $0.description }) == expectedVisibleItemDescriptions,
      "Unexpected visible items.")

    XCTAssert(
      details.centermostLayoutItem
        .description == "[itemType: .layoutItemType(.day(2020-12-01)), frame: (96.5, 875.5, 35.5, 35.5)]",
      "Unexpected centermost layout item.")

    XCTAssert(details.contentStartBoundary == nil, "Unexpected content start offset.")
    XCTAssert(
      details.contentEndBoundary?.alignedToPixel(forScreenWithScale: 3) == CGFloat(911.4285714285714)
        .alignedToPixel(forScreenWithScale: 3),
      "Unexpected content end offset.")
  }

  func testBoundaryHorizontalVisibleItemsContext() {
    let details = horizontalVisibleItemsProvider.detailsForVisibleItems(
      surroundingPreviouslyVisibleLayoutItem: LayoutItem(
        itemType: .monthHeader(Month(era: 1, year: 2020, month: 12, isInGregorianCalendar: true)),
        frame: CGRect(x: 1200, y: 0, width: 300, height: 50)),
      offset: CGPoint(x: 1000, y: 0),
      extendLayoutRegion: false)

    let expectedVisibleItemDescriptions: Set<String> = [
      "[itemType: .dayBackground(2020-11-11), frame: (1018.5, 235.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-11-12), frame: (1061.5, 235.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-11-13), frame: (1104.5, 235.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-11-14), frame: (1147.0, 235.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-11-17), frame: (975.5, 288.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-11-18), frame: (1018.5, 288.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-11-19), frame: (1061.5, 288.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-12-13), frame: (1205.0, 288.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-12-14), frame: (1248.0, 288.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-12-15), frame: (1290.5, 288.5, 33.0, 33.0)]",
      "[itemType: .daysOfWeekRowSeparator(2020-11), frame: (885.0, 162.0, 300.0, 1.0)]",
      "[itemType: .daysOfWeekRowSeparator(2020-12), frame: (1200.0, 162.0, 300.0, 1.0)]",
      "[itemType: .layoutItemType(.day(2020-11-03)), frame: (975.5, 183.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-11-04)), frame: (1018.5, 183.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-11-05)), frame: (1061.5, 183.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-11-06)), frame: (1104.5, 183.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-11-07)), frame: (1147.0, 183.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-11-10)), frame: (975.5, 235.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-11-11)), frame: (1018.5, 235.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-11-12)), frame: (1061.5, 235.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-11-13)), frame: (1104.5, 235.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-11-14)), frame: (1147.0, 235.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-11-17)), frame: (975.5, 288.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-11-18)), frame: (1018.5, 288.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-11-19)), frame: (1061.5, 288.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-11-20)), frame: (1104.5, 288.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-11-21)), frame: (1147.0, 288.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-11-24)), frame: (975.5, 341.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-11-25)), frame: (1018.5, 341.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-11-26)), frame: (1061.5, 341.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-11-27)), frame: (1104.5, 341.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-11-28)), frame: (1147.0, 341.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-12-01)), frame: (1290.5, 183.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-12-06)), frame: (1205.0, 235.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-12-07)), frame: (1248.0, 235.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-12-08)), frame: (1290.5, 235.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-12-13)), frame: (1205.0, 288.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-12-14)), frame: (1248.0, 288.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-12-15)), frame: (1290.5, 288.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-12-20)), frame: (1205.0, 341.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-12-21)), frame: (1248.0, 341.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-12-22)), frame: (1290.5, 341.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-12-27)), frame: (1205.0, 394.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-12-28)), frame: (1248.0, 394.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-12-29)), frame: (1290.5, 394.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.fifth, 2020-11)), frame: (1061.5, 130.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.first, 2020-12)), frame: (1205.0, 130.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.fourth, 2020-11)), frame: (1018.5, 130.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.last, 2020-11)), frame: (1147.0, 130.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.second, 2020-12)), frame: (1248.0, 130.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.sixth, 2020-11)), frame: (1104.5, 130.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.third, 2020-11)), frame: (975.5, 130.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.third, 2020-12)), frame: (1290.5, 130.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.monthHeader(2020-11)), frame: (885.0, 50.0, 300.0, 50.0)]",
      "[itemType: .layoutItemType(.monthHeader(2020-12)), frame: (1200.0, 0.0, 300.0, 100.0)]",
      "[itemType: .monthBackground(2020-11), frame: (877.5, -1.5, 315.0, 480.0)]",
      "[itemType: .monthBackground(2020-12), frame: (1192.5, -26.5, 315.0, 480.0)]",
      "[itemType: .overlayItem(.monthHeader(2020-11)), frame: (1000.0, 0.0, 320.0, 480.0)]",
    ]

    XCTAssert(
      Set(details.visibleItems.map { $0.description }) == expectedVisibleItemDescriptions,
      "Unexpected visible items.")

    XCTAssert(
      details.centermostLayoutItem
        .description == "[itemType: .layoutItemType(.day(2020-11-14)), frame: (1147.0, 235.5, 33.0, 33.0)]",
      "Unexpected centermost layout item.")

    XCTAssert(details.contentStartBoundary == nil, "Unexpected content start offset.")
    XCTAssert(details.contentEndBoundary == 1500, "Unexpected content end offset.")
  }

  // MARK: Animated update pass tests

  func testVerticalVisibleItemsForAnimatedUpdatePass() {
    let details = verticalPinnedDaysOfWeekVisibleItemsProvider.detailsForVisibleItems(
      surroundingPreviouslyVisibleLayoutItem: LayoutItem(
        itemType: .monthHeader(Month(era: 1, year: 2020, month: 06, isInGregorianCalendar: true)),
        frame: CGRect(x: 0, y: 450, width: 320, height: 40)),
      offset: CGPoint(x: 0, y: 450),
      extendLayoutRegion: true)

    let expectedVisibleItemDescriptions: Set<String> = [
      "[itemType: .dayBackground(2020-04-19), frame: (5.0, -65.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-05-11), frame: (50.5, 232.0, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-05-12), frame: (96.5, 232.0, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-05-13), frame: (142.0, 232.0, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-05-14), frame: (188.0, 232.0, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-05-15), frame: (233.5, 232.0, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-05-16), frame: (279.5, 232.0, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-05-17), frame: (5.0, 288.0, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-05-18), frame: (50.5, 288.0, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-05-19), frame: (96.5, 288.0, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-06-11), frame: (188.0, 585.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-06-12), frame: (233.5, 585.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-06-13), frame: (279.5, 585.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-06-14), frame: (5.0, 641.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-06-15), frame: (50.5, 641.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-06-16), frame: (96.5, 641.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-06-17), frame: (142.0, 641.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-06-18), frame: (188.0, 641.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-06-19), frame: (233.5, 641.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-07-11), frame: (279.5, 939.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-07-12), frame: (5.0, 995.0, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-07-13), frame: (50.5, 995.0, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-07-14), frame: (96.5, 995.0, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-07-15), frame: (142.0, 995.0, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-07-16), frame: (188.0, 995.0, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-07-17), frame: (233.5, 995.0, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-07-18), frame: (279.5, 995.0, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-07-19), frame: (5.0, 1050.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-08-11), frame: (96.5, 1398.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-08-12), frame: (142.0, 1398.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-08-13), frame: (188.0, 1398.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-08-14), frame: (233.5, 1398.5, 35.5, 35.5)]",
      "[itemType: .dayBackground(2020-08-15), frame: (279.5, 1398.5, 35.5, 35.5)]",
      "[itemType: .dayRange(2020-04-30, 2020-05-14), frame: (5.0, -10.0, 310.0, 278.0)]",
      "[itemType: .layoutItemType(.day(2020-04-19)), frame: (5.0, -65.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-04-20)), frame: (50.5, -65.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-04-21)), frame: (96.5, -65.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-04-22)), frame: (142.0, -65.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-04-23)), frame: (188.0, -65.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-04-24)), frame: (233.5, -65.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-04-25)), frame: (279.5, -65.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-04-26)), frame: (5.0, -10.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-04-27)), frame: (50.5, -10.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-04-28)), frame: (96.5, -10.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-04-29)), frame: (142.0, -10.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-04-30)), frame: (188.0, -10.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-01)), frame: (233.5, 120.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-02)), frame: (279.5, 120.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-03)), frame: (5.0, 176.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-04)), frame: (50.5, 176.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-05)), frame: (96.5, 176.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-06)), frame: (142.0, 176.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-07)), frame: (188.0, 176.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-08)), frame: (233.5, 176.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-09)), frame: (279.5, 176.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-10)), frame: (5.0, 232.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-11)), frame: (50.5, 232.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-12)), frame: (96.5, 232.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-13)), frame: (142.0, 232.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-14)), frame: (188.0, 232.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-15)), frame: (233.5, 232.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-16)), frame: (279.5, 232.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-17)), frame: (5.0, 288.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-18)), frame: (50.5, 288.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-19)), frame: (96.5, 288.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-20)), frame: (142.0, 288.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-21)), frame: (188.0, 288.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-22)), frame: (233.5, 288.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-23)), frame: (279.5, 288.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-24)), frame: (5.0, 343.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-25)), frame: (50.5, 343.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-26)), frame: (96.5, 343.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-27)), frame: (142.0, 343.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-28)), frame: (188.0, 343.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-29)), frame: (233.5, 343.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-30)), frame: (279.5, 343.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-05-31)), frame: (5.0, 399.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-01)), frame: (50.5, 530.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-02)), frame: (96.5, 530.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-03)), frame: (142.0, 530.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-04)), frame: (188.0, 530.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-05)), frame: (233.5, 530.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-06)), frame: (279.5, 530.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-07)), frame: (5.0, 585.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-08)), frame: (50.5, 585.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-09)), frame: (96.5, 585.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-10)), frame: (142.0, 585.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-11)), frame: (188.0, 585.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-12)), frame: (233.5, 585.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-13)), frame: (279.5, 585.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-14)), frame: (5.0, 641.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-15)), frame: (50.5, 641.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-16)), frame: (96.5, 641.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-17)), frame: (142.0, 641.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-18)), frame: (188.0, 641.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-19)), frame: (233.5, 641.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-20)), frame: (279.5, 641.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-21)), frame: (5.0, 697.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-22)), frame: (50.5, 697.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-23)), frame: (96.5, 697.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-24)), frame: (142.0, 697.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-25)), frame: (188.0, 697.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-26)), frame: (233.5, 697.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-27)), frame: (279.5, 697.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-28)), frame: (5.0, 753.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-29)), frame: (50.5, 753.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-06-30)), frame: (96.5, 753.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-01)), frame: (142.0, 883.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-02)), frame: (188.0, 883.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-03)), frame: (233.5, 883.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-04)), frame: (279.5, 883.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-05)), frame: (5.0, 939.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-06)), frame: (50.5, 939.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-07)), frame: (96.5, 939.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-08)), frame: (142.0, 939.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-09)), frame: (188.0, 939.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-10)), frame: (233.5, 939.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-11)), frame: (279.5, 939.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-12)), frame: (5.0, 995.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-13)), frame: (50.5, 995.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-14)), frame: (96.5, 995.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-15)), frame: (142.0, 995.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-16)), frame: (188.0, 995.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-17)), frame: (233.5, 995.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-18)), frame: (279.5, 995.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-19)), frame: (5.0, 1050.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-20)), frame: (50.5, 1050.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-21)), frame: (96.5, 1050.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-22)), frame: (142.0, 1050.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-23)), frame: (188.0, 1050.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-24)), frame: (233.5, 1050.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-25)), frame: (279.5, 1050.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-26)), frame: (5.0, 1106.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-27)), frame: (50.5, 1106.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-28)), frame: (96.5, 1106.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-29)), frame: (142.0, 1106.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-30)), frame: (188.0, 1106.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-07-31)), frame: (233.5, 1106.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-08-01)), frame: (279.5, 1287.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-08-02)), frame: (5.0, 1343.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-08-03)), frame: (50.5, 1343.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-08-04)), frame: (96.5, 1343.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-08-05)), frame: (142.0, 1343.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-08-06)), frame: (188.0, 1343.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-08-07)), frame: (233.5, 1343.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-08-08)), frame: (279.5, 1343.0, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-08-09)), frame: (5.0, 1398.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-08-10)), frame: (50.5, 1398.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-08-11)), frame: (96.5, 1398.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-08-12)), frame: (142.0, 1398.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-08-13)), frame: (188.0, 1398.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-08-14)), frame: (233.5, 1398.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.day(2020-08-15)), frame: (279.5, 1398.5, 35.5, 35.5)]",
      "[itemType: .layoutItemType(.monthHeader(2020-05)), frame: (0.0, 40.5, 320.0, 50.0)]",
      "[itemType: .layoutItemType(.monthHeader(2020-06)), frame: (0.0, 450.0, 320.0, 50.0)]",
      "[itemType: .layoutItemType(.monthHeader(2020-07)), frame: (0.0, 803.5, 320.0, 50.0)]",
      "[itemType: .layoutItemType(.monthHeader(2020-08)), frame: (0.0, 1157.0, 320.0, 100.0)]",
      "[itemType: .monthBackground(2020-04), frame: (0.0, -370.5, 320.0, 403.5)]",
      "[itemType: .monthBackground(2020-05), frame: (0.0, 33.0, 320.0, 409.5)]",
      "[itemType: .monthBackground(2020-06), frame: (0.0, 442.5, 320.0, 353.5)]",
      "[itemType: .monthBackground(2020-07), frame: (0.0, 796.0, 320.0, 353.5)]",
      "[itemType: .monthBackground(2020-08), frame: (0.0, 1149.5, 320.0, 459.5)]",
      "[itemType: .pinnedDayOfWeek(.fifth), frame: (188.0, 450.0, 35.5, 35.5)]",
      "[itemType: .pinnedDayOfWeek(.first), frame: (5.0, 450.0, 35.5, 35.5)]",
      "[itemType: .pinnedDayOfWeek(.fourth), frame: (142.0, 450.0, 35.5, 35.5)]",
      "[itemType: .pinnedDayOfWeek(.last), frame: (279.5, 450.0, 35.5, 35.5)]",
      "[itemType: .pinnedDayOfWeek(.second), frame: (50.5, 450.0, 35.5, 35.5)]",
      "[itemType: .pinnedDayOfWeek(.sixth), frame: (233.5, 450.0, 35.5, 35.5)]",
      "[itemType: .pinnedDayOfWeek(.third), frame: (96.5, 450.0, 35.5, 35.5)]",
      "[itemType: .pinnedDaysOfWeekRowBackground, frame: (0.0, 450.0, 320.0, 35.5)]",
      "[itemType: .pinnedDaysOfWeekRowSeparator, frame: (0.0, 484.5, 320.0, 1.0)]",
    ]

    XCTAssert(
      Set(details.visibleItems.map { $0.description }) == expectedVisibleItemDescriptions,
      "Unexpected visible items.")
  }

  func testHorizontalVisibleItemsForAnimatedUpdatePass() {
    let details = horizontalVisibleItemsProvider.detailsForVisibleItems(
      surroundingPreviouslyVisibleLayoutItem: LayoutItem(
        itemType: .monthHeader(Month(era: 1, year: 2020, month: 05, isInGregorianCalendar: true)),
        frame: CGRect(x: 250, y: 0, width: 300, height: 50)),
      offset: CGPoint(x: 100, y: 0),
      extendLayoutRegion: true)

    let expectedVisibleItemDescriptions: Set<String> = [
      "[itemType: .dayBackground(2020-03-11), frame: (-246.5, 185.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-03-12), frame: (-203.5, 185.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-03-13), frame: (-160.5, 185.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-03-14), frame: (-118.0, 185.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-03-18), frame: (-246.5, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-03-19), frame: (-203.5, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-04-11), frame: (197.0, 185.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-04-12), frame: (-60.0, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-04-13), frame: (-17.0, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-04-14), frame: (25.5, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-04-15), frame: (68.5, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-04-16), frame: (111.5, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-04-17), frame: (154.5, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-04-18), frame: (197.0, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-04-19), frame: (-60.0, 291.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-05-11), frame: (298.0, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-05-12), frame: (340.5, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-05-13), frame: (383.5, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-05-14), frame: (426.5, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-05-15), frame: (469.5, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-05-16), frame: (512.0, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-05-17), frame: (255.0, 291.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-05-18), frame: (298.0, 291.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-05-19), frame: (340.5, 291.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-06-14), frame: (570.0, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-06-15), frame: (613.0, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-06-16), frame: (655.5, 238.5, 33.0, 33.0)]",
      "[itemType: .dayBackground(2020-06-17), frame: (698.5, 238.5, 33.0, 33.0)]",
      "[itemType: .dayRange(2020-03-11, 2020-04-05), frame: (-375.0, 133.0, 605.0, 244.5)]",
      "[itemType: .dayRange(2020-04-30, 2020-05-14), frame: (111.5, 133.0, 433.5, 244.5)]",
      "[itemType: .daysOfWeekRowSeparator(2020-3), frame: (-380.0, 112.0, 300.0, 1.0)]",
      "[itemType: .daysOfWeekRowSeparator(2020-4), frame: (-65.0, 112.0, 300.0, 1.0)]",
      "[itemType: .daysOfWeekRowSeparator(2020-5), frame: (250.0, 112.0, 300.0, 1.0)]",
      "[itemType: .daysOfWeekRowSeparator(2020-6), frame: (565.0, 112.0, 300.0, 1.0)]",
      "[itemType: .layoutItemType(.day(2020-03-04)), frame: (-246.5, 133.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-03-05)), frame: (-203.5, 133.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-03-06)), frame: (-160.5, 133.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-03-07)), frame: (-118.0, 133.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-03-11)), frame: (-246.5, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-03-12)), frame: (-203.5, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-03-13)), frame: (-160.5, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-03-14)), frame: (-118.0, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-03-18)), frame: (-246.5, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-03-19)), frame: (-203.5, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-03-20)), frame: (-160.5, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-03-21)), frame: (-118.0, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-03-25)), frame: (-246.5, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-03-26)), frame: (-203.5, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-03-27)), frame: (-160.5, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-03-28)), frame: (-118.0, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-01)), frame: (68.5, 133.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-02)), frame: (111.5, 133.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-03)), frame: (154.5, 133.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-04)), frame: (197.0, 133.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-05)), frame: (-60.0, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-06)), frame: (-17.0, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-07)), frame: (25.5, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-08)), frame: (68.5, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-09)), frame: (111.5, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-10)), frame: (154.5, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-11)), frame: (197.0, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-12)), frame: (-60.0, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-13)), frame: (-17.0, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-14)), frame: (25.5, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-15)), frame: (68.5, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-16)), frame: (111.5, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-17)), frame: (154.5, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-18)), frame: (197.0, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-19)), frame: (-60.0, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-20)), frame: (-17.0, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-21)), frame: (25.5, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-22)), frame: (68.5, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-23)), frame: (111.5, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-24)), frame: (154.5, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-25)), frame: (197.0, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-26)), frame: (-60.0, 344.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-27)), frame: (-17.0, 344.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-28)), frame: (25.5, 344.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-29)), frame: (68.5, 344.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-04-30)), frame: (111.5, 344.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-01)), frame: (469.5, 133.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-02)), frame: (512.0, 133.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-03)), frame: (255.0, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-04)), frame: (298.0, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-05)), frame: (340.5, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-06)), frame: (383.5, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-07)), frame: (426.5, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-08)), frame: (469.5, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-09)), frame: (512.0, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-10)), frame: (255.0, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-11)), frame: (298.0, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-12)), frame: (340.5, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-13)), frame: (383.5, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-14)), frame: (426.5, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-15)), frame: (469.5, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-16)), frame: (512.0, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-17)), frame: (255.0, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-18)), frame: (298.0, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-19)), frame: (340.5, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-20)), frame: (383.5, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-21)), frame: (426.5, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-22)), frame: (469.5, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-23)), frame: (512.0, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-24)), frame: (255.0, 344.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-25)), frame: (298.0, 344.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-26)), frame: (340.5, 344.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-27)), frame: (383.5, 344.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-28)), frame: (426.5, 344.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-29)), frame: (469.5, 344.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-30)), frame: (512.0, 344.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-05-31)), frame: (255.0, 397.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-06-01)), frame: (613.0, 133.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-06-02)), frame: (655.5, 133.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-06-03)), frame: (698.5, 133.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-06-07)), frame: (570.0, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-06-08)), frame: (613.0, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-06-09)), frame: (655.5, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-06-10)), frame: (698.5, 185.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-06-14)), frame: (570.0, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-06-15)), frame: (613.0, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-06-16)), frame: (655.5, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-06-17)), frame: (698.5, 238.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-06-21)), frame: (570.0, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-06-22)), frame: (613.0, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-06-23)), frame: (655.5, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-06-24)), frame: (698.5, 291.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-06-28)), frame: (570.0, 344.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-06-29)), frame: (613.0, 344.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.day(2020-06-30)), frame: (655.5, 344.5, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.fifth, 2020-03)), frame: (-203.5, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.fifth, 2020-04)), frame: (111.5, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.fifth, 2020-05)), frame: (426.5, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.first, 2020-04)), frame: (-60.0, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.first, 2020-05)), frame: (255.0, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.first, 2020-06)), frame: (570.0, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.fourth, 2020-03)), frame: (-246.5, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.fourth, 2020-04)), frame: (68.5, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.fourth, 2020-05)), frame: (383.5, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.fourth, 2020-06)), frame: (698.5, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.last, 2020-03)), frame: (-118.0, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.last, 2020-04)), frame: (197.0, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.last, 2020-05)), frame: (512.0, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.second, 2020-04)), frame: (-17.0, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.second, 2020-05)), frame: (298.0, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.second, 2020-06)), frame: (613.0, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.sixth, 2020-03)), frame: (-160.5, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.sixth, 2020-04)), frame: (154.5, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.sixth, 2020-05)), frame: (469.5, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.third, 2020-04)), frame: (25.5, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.third, 2020-05)), frame: (340.5, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.dayOfWeekInMonth(.third, 2020-06)), frame: (655.5, 80.0, 33.0, 33.0)]",
      "[itemType: .layoutItemType(.monthHeader(2020-03)), frame: (-380.0, 0.0, 300.0, 50.0)]",
      "[itemType: .layoutItemType(.monthHeader(2020-04)), frame: (-65.0, -50.0, 300.0, 100.0)]",
      "[itemType: .layoutItemType(.monthHeader(2020-05)), frame: (250.0, 0.0, 300.0, 50.0)]",
      "[itemType: .layoutItemType(.monthHeader(2020-06)), frame: (565.0, 0.0, 300.0, 50.0)]",
      "[itemType: .monthBackground(2020-03), frame: (-387.5, -51.5, 315.0, 480.0)]",
      "[itemType: .monthBackground(2020-04), frame: (-72.5, -76.5, 315.0, 480.0)]",
      "[itemType: .monthBackground(2020-05), frame: (242.5, -25.0, 315.0, 480.0)]",
      "[itemType: .monthBackground(2020-06), frame: (557.5, -51.5, 315.0, 480.0)]",
    ]

    XCTAssert(
      Set(details.visibleItems.map { $0.description }) == expectedVisibleItemDescriptions,
      "Unexpected visible items.")
  }

  // MARK: Private

  private static let calendar = Calendar(identifier: .gregorian)

  private static let dateRange = ClosedRange(
    uncheckedBounds: (
      lower: calendar.startDate(
        of: Day(month: Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true), day: 25)),
      upper: calendar.startDate(
        of: Day(
          month: Month(era: 1, year: 2020, month: 12, isInGregorianCalendar: true),
          day: 01))))

  private static let size = CGSize(width: 320, height: 480)

  private var verticalVisibleItemsProvider = VisibleItemsProvider(
    calendar: calendar,
    content: makeContent(
      fromBaseContent: CalendarViewContent(
        calendar: calendar,
        visibleDateRange: dateRange,
        monthsLayout: .vertical(options: VerticalMonthsLayoutOptions()))),
    size: size,
    layoutMargins: .zero,
    scale: 2,
    backgroundColor: nil)

  private var verticalShortDayAspectRatioVisibleItemsProvider = VisibleItemsProvider(
    calendar: calendar,
    content: makeContent(
      fromBaseContent: CalendarViewContent(
        calendar: calendar,
        visibleDateRange: dateRange,
        monthsLayout: .vertical(options: VerticalMonthsLayoutOptions())))
      .dayAspectRatio(0.5)
      .dayOfWeekAspectRatio(0.5),
    size: size,
    layoutMargins: .zero,
    scale: 2,
    backgroundColor: nil)

  private var verticalPinnedDaysOfWeekVisibleItemsProvider = VisibleItemsProvider(
    calendar: calendar,
    content: makeContent(
      fromBaseContent: CalendarViewContent(
        calendar: calendar,
        visibleDateRange: dateRange,
        monthsLayout: .vertical(options: VerticalMonthsLayoutOptions(pinDaysOfWeekToTop: true)))),
    size: size,
    layoutMargins: .zero,
    scale: 2,
    backgroundColor: nil)

  private var verticalPartialMonthVisibleItemsProvider = VisibleItemsProvider(
    calendar: calendar,
    content: makeContent(
      fromBaseContent: CalendarViewContent(
        calendar: calendar,
        visibleDateRange: dateRange,
        monthsLayout: .vertical(
          options: VerticalMonthsLayoutOptions(alwaysShowCompleteBoundaryMonths: false)))),
    size: size,
    layoutMargins: .zero,
    scale: 2,
    backgroundColor: nil)

  private var horizontalVisibleItemsProvider = VisibleItemsProvider(
    calendar: calendar,
    content: makeContent(
      fromBaseContent: CalendarViewContent(
        calendar: calendar,
        visibleDateRange: dateRange,
        monthsLayout: .horizontal(
          options: HorizontalMonthsLayoutOptions(maximumFullyVisibleMonths: 64 / 63)))),
    size: size,
    layoutMargins: .zero,
    scale: 2,
    backgroundColor: nil)

  private static func mockCalendarItemModel(height: CGFloat = 50) -> AnyCalendarItemModel {
    final class MockView: UIView, CalendarItemViewRepresentable {

      typealias Height = CGFloat

      static func makeView(
        withInvariantViewProperties height: Height)
        -> MockView
      {
        let view = MockView()
        let heightConstraint = view.heightAnchor.constraint(equalToConstant: height)
        heightConstraint.priority = .defaultLow
        heightConstraint.isActive = true
        return view
      }

    }

    return MockView.calendarItemModel(invariantViewProperties: height)
  }

  private static func makeContent(
    fromBaseContent baseContent: CalendarViewContent)
    -> CalendarViewContent
  {
    baseContent
      .monthDayInsets(.init(top: 30, leading: 5, bottom: 0, trailing: 5))
      .interMonthSpacing(15)
      .verticalDayMargin(20)
      .horizontalDayMargin(10)
      .daysOfTheWeekRowSeparator(options: .init(height: 1, color: .gray))
      .monthHeaderItemProvider { month in
        if month.month % 4 == 0 {
          return mockCalendarItemModel(height: 100)
        } else {
          return mockCalendarItemModel()
        }
      }
      .monthBackgroundItemProvider { _ in mockCalendarItemModel() }
      .dayOfWeekItemProvider { _, _ in mockCalendarItemModel() }
      .dayItemProvider { _ in mockCalendarItemModel() }
      .dayBackgroundItemProvider { day in
        // Just test a few backgrounds to make sure they're working correctly
        if day.day > 10, day.day < 20 {
          return mockCalendarItemModel()
        } else {
          return nil
        }
      }
      .dayRangeItemProvider(
        for: [
          calendar.date(from: DateComponents(year: 2020, month: 03, day: 11))!
            ...
            calendar.date(from: DateComponents(year: 2020, month: 04, day: 05))!,

          calendar.date(from: DateComponents(year: 2020, month: 04, day: 30))!
            ...
            calendar.date(from: DateComponents(year: 2020, month: 05, day: 14))!,
        ]) { _ in mockCalendarItemModel() }
      .overlayItemProvider(
        for: [
          .day(
            containingDate: calendar.date(from: DateComponents(year: 2020, month: 01, day: 19))!),
          .monthHeader(
            monthContainingDate: calendar.date(from: DateComponents(year: 2020, month: 11))!),
        ]) { _ in mockCalendarItemModel() }
  }

}

// MARK: - VisibleItem + CustomStringConvertible

extension VisibleItem: CustomStringConvertible {

  public var description: String {
    let itemTypeText: String
    switch itemType {
    case .layoutItemType(let layoutItemType):
      itemTypeText = layoutItemType.description
    case .pinnedDayOfWeek(let position):
      itemTypeText = ".pinnedDayOfWeek(\(position))"
    case .pinnedDaysOfWeekRowBackground:
      itemTypeText = ".pinnedDaysOfWeekRowBackground"
    case .pinnedDaysOfWeekRowSeparator:
      itemTypeText = ".pinnedDaysOfWeekRowSeparator"
    case .daysOfWeekRowSeparator(let month):
      itemTypeText = ".daysOfWeekRowSeparator(\(month.year)-\(month.month))"
    case .dayRange(let dayRange):
      itemTypeText = ".dayRange(\(dayRange.lowerBound), \(dayRange.upperBound))"
    case .dayBackground(let day):
      itemTypeText = ".dayBackground(\(day))"
    case .monthBackground(let month):
      itemTypeText = ".monthBackground(\(month.description))"
    case .overlayItem(let overlaidItemLocation):
      let calendar = Calendar(identifier: .gregorian)
      let itemLocationText: String
      switch overlaidItemLocation {
      case .day(let date):
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        itemLocationText = ".day(\(year)-\(month)-\(day))"
      case .monthHeader(let date):
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        itemLocationText = ".monthHeader(\(year)-\(month))"
      }
      itemTypeText = ".overlayItem(\(itemLocationText))"
    }

    let frameText = frame.alignedToPixels(forScreenWithScale: 2).debugDescription
    return "[itemType: \(itemTypeText), frame: \(frameText)]"
  }

}

// MARK: - LayoutItem + CustomStringConvertible

extension LayoutItem: CustomStringConvertible {

  public var description: String {
    let frameText = frame.alignedToPixels(forScreenWithScale: 2).debugDescription
    return "[itemType: \(itemType.description), frame: \(frameText)]"
  }

}

// MARK: - LayoutItem.ItemType + CustomStringConvertible

extension LayoutItem.ItemType: CustomStringConvertible {

  public var description: String {
    switch self {
    case .monthHeader(let month):
      return ".layoutItemType(.monthHeader(\(month.description)))"
    case .dayOfWeekInMonth(let position, let month):
      return ".layoutItemType(.dayOfWeekInMonth(\(position.description), \(month.description)))"
    case .day(let day):
      return ".layoutItemType(.day(\(day)))"
    }
  }

}

// MARK: - DayOfWeekPosition + CustomStringConvertible

extension DayOfWeekPosition: CustomStringConvertible {

  public var description: String {
    switch self {
    case .first: return ".first"
    case .second: return ".second"
    case .third: return ".third"
    case .fourth: return ".fourth"
    case .fifth: return ".fifth"
    case .sixth: return ".sixth"
    case .last: return ".last"
    }
  }

}
