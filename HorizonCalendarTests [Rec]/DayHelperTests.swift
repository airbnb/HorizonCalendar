// Created by Bryan Keller on 6/7/20.
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

// MARK: - DayHelperTests

final class DayHelperTests: XCTestCase {

  // MARK: Internal

  func testDayComparable() {
    let january2020Day = Day(
      month: Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true),
      day: 19)
    let december2020Day = Day(
      month: Month(era: 1, year: 2020, month: 12, isInGregorianCalendar: true),
      day: 05)
    XCTAssert(january2020Day < december2020Day, "Expected January 19, 2020 < December 5, 2020.")

    let june0006Day = Day(
      month: Month(era: 0, year: 0006, month: 06, isInGregorianCalendar: true),
      day: 10)
    let january0005Day = Day(
      month: Month(era: 1, year: 0005, month: 01, isInGregorianCalendar: true),
      day: 09)
    XCTAssert(june0006Day < january0005Day, "Expected June 10, 0006 BCE < January 9, 0005 CE.")

    let june30Day = Day(
      month: Month(era: 235, year: 30, month: 06, isInGregorianCalendar: false),
      day: 25)
    let august01Day = Day(
      month: Month(era: 236, year: 01, month: 08, isInGregorianCalendar: false),
      day: 30)
    XCTAssert(june30Day < august01Day, "Expected June 30, 30 era 235 < August 30, 02 era 236.")
  }

  func testDayContainingDate() {
    let january2020Date = gregorianCalendar.date(
      from: DateComponents(year: 2020, month: 01, day: 19))!
    let january2020Day = Day(
      month: Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true),
      day: 19)
    XCTAssert(
      gregorianCalendar.day(containing: january2020Date) == january2020Day,
      "Expected the day to be January 19, 2020.")

    let december0005Date = gregorianCalendar.date(
      from: DateComponents(era: 0, year: 0005, month: 12, day: 08))!
    let december0005Day = Day(
      month: Month(era: 0, year: 0005, month: 12, isInGregorianCalendar: true),
      day: 08)
    XCTAssert(
      gregorianCalendar.day(containing: december0005Date) == december0005Day,
      "Expected the day to be December 8, 0005.")

    let september02Date = japaneseCalendar.date(
      from: DateComponents(era: 236, year: 02, month: 09, day: 21))!
    let september02Day = Day(
      month: Month(era: 236, year: 02, month: 09, isInGregorianCalendar: false),
      day: 21)
    XCTAssert(
      japaneseCalendar.day(containing: september02Date) == september02Day,
      "Expected the day to be September 21, 02.")
  }

  func testStartDateOfDay() {
    let november2020Day = Day(
      month: Month(era: 1, year: 2020, month: 11, isInGregorianCalendar: true),
      day: 17)
    let november2020Date = gregorianCalendar.date(
      from: DateComponents(year: 2020, month: 11, day: 17))!
    XCTAssert(
      gregorianCalendar.startDate(of: november2020Day) == november2020Date,
      "Expected the date to be the earliest possible time for November 17, 2020.")

    let january0100Day = Day(
      month: Month(era: 0, year: 0100, month: 01, isInGregorianCalendar: true),
      day: 14)
    let january0100Date = gregorianCalendar.date(
      from: DateComponents(era: 0, year: 0100, month: 01, day: 14))!
    XCTAssert(
      gregorianCalendar.startDate(of: january0100Day) == january0100Date,
      "Expected the date to be the earliest possible time for January 14, 0100 BCE.")

    let june02Day = Day(
      month: Month(era: 236, year: 02, month: 06, isInGregorianCalendar: false),
      day: 11)
    let june02Date = japaneseCalendar.date(
      from: DateComponents(era: 236, year: 02, month: 06, day: 11))!
    XCTAssert(
      japaneseCalendar.startDate(of: june02Day) == june02Date,
      "Expected the date to be the earliest possible time for June 11, 02.")
  }

  func testDayByAddingDays() {
    let january2021Day = Day(
      month: Month(era: 1, year: 2021, month: 01, isInGregorianCalendar: true),
      day: 19)
    let june2020Day = Day(
      month: Month(era: 1, year: 2020, month: 11, isInGregorianCalendar: true),
      day: 16)
    XCTAssert(
      gregorianCalendar.day(byAddingDays: -64, to: january2021Day) == june2020Day,
      "Expected January 19, 2021 - 100 = June 16, 2020.")

    let april0069Day = Day(
      month: Month(era: 0, year: 0069, month: 04, isInGregorianCalendar: true),
      day: 20)
    let may0069Day = Day(
      month: Month(era: 0, year: 0069, month: 05, isInGregorianCalendar: true),
      day: 01)
    XCTAssert(
      gregorianCalendar.day(byAddingDays: 11, to: april0069Day) == may0069Day,
      "Expected April 20, 0069 BCE + 12 = May 01, 0069 BCE.")

    let january02Day = Day(
      month: Month(era: 236, year: 02, month: 01, isInGregorianCalendar: false),
      day: 01)
    let december01Day = Day(
      month: Month(era: 236, year: 01, month: 12, isInGregorianCalendar: false),
      day: 31)
    XCTAssert(
      japaneseCalendar.day(byAddingDays: -1, to: january02Day) == december01Day,
      "Expected January 1, 02 - 1 = December 31, 01.")
  }

  // MARK: Private

  private lazy var gregorianCalendar = Calendar(identifier: .gregorian)
  private lazy var japaneseCalendar = Calendar(identifier: .japanese)

}
