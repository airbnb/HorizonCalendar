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

// MARK: - MonthHelperTests

final class MonthHelperTests: XCTestCase {

  // MARK: Internal

  func testMonthComparable() {
    let december0001BCE = Month(era: 0, year: 0001, month: 12, isInGregorianCalendar: true)
    let january0001CE = Month(era: 1, year: 0001, month: 01, isInGregorianCalendar: true)
    XCTAssert(
      december0001BCE < january0001CE,
      "Expected December 0001 BCE < January 0001 CE.")

    let february2020 = Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true)
    let january2019 = Month(era: 1, year: 2019, month: 01, isInGregorianCalendar: true)
    XCTAssert(
      february2020 > january2019,
      "Expected February 2020 > 2019.")

    let march02 = Month(era: 236, year: 02, month: 03, isInGregorianCalendar: false)
    let may29 = Month(era: 235, year: 29, month: 05, isInGregorianCalendar: false)
    XCTAssert(
      march02 > may29,
      "Expected March 02 era 236 > May 29 era 235.")
  }

  func testMonthContainingDate() {
    let january2020Date = gregorianCalendar.date(
      from: DateComponents(year: 2020, month: 01, day: 19))!
    let january2020 = gregorianCalendar.month(containing: january2020Date)
    XCTAssert(
      january2020 == Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true),
      "Expected the month to be January 2020.")

    let december0050Date = gregorianCalendar.date(
      from: DateComponents(era: 0, year: 0050, month: 12, day: 31))!
    let december0050 = gregorianCalendar.month(containing: december0050Date)
    XCTAssert(
      december0050 == Month(era: 0, year: 0050, month: 12, isInGregorianCalendar: true),
      "Expected the month to be December 0050 BCE.")

    let september02Date = japaneseCalendar.date(
      from: DateComponents(era: 236, year: 02, month: 09, day: 01))!
    let september02 = japaneseCalendar.month(containing: september02Date)
    XCTAssert(
      september02 == Month(era: 236, year: 02, month: 09, isInGregorianCalendar: false),
      "Expected the month to be September 02.")
  }

  func testFirstDateOfMonth() {
    let january2020Date = gregorianCalendar.firstDate(
      of: Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true))
    let january2020ExpectedDate = gregorianCalendar.date(
      from: DateComponents(era: 1, year: 2020, month: 01, day: 01))!
    XCTAssert(
      january2020Date == january2020ExpectedDate,
      "Expected the date to be the earliest possible time for January 2020.")

    let april0050Date = gregorianCalendar.firstDate(
      of: Month(era: 0, year: 0050, month: 04, isInGregorianCalendar: true))
    let april0050ExpectedDate = gregorianCalendar.date(
      from: DateComponents(era: 0, year: 0050, month: 04, day: 01))!
    XCTAssert(
      april0050Date == april0050ExpectedDate,
      "Expected the date to be the earliest possible time for April 0050 BCE.")

    let may05Date = japaneseCalendar.firstDate(
      of: Month(era: 236, year: 05, month: 05, isInGregorianCalendar: false))
    let may05ExpectedDate = japaneseCalendar.date(
      from: DateComponents(era: 236, year: 05, month: 05, day: 01))!
    XCTAssert(
      may05Date == may05ExpectedDate,
      "Expected the date to be the earliest possible time for May 05.")
  }

  func testLastDateOfMonth() {
    let february2020Date = gregorianCalendar.lastDate(
      of: Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true))
    let february2020ExpectedDate = gregorianCalendar.date(
      from: DateComponents(era: 1, year: 2020, month: 02, day: 29))!
    XCTAssert(
      february2020Date == february2020ExpectedDate,
      "Expected the date to be the earliest possible time for the last day of February 2020.")

    let october0050Date = gregorianCalendar.lastDate(
      of: Month(era: 0, year: 0050, month: 10, isInGregorianCalendar: true))
    let october0050ExpectedDate = gregorianCalendar.date(
      from: DateComponents(era: 0, year: 0050, month: 10, day: 31))!
    XCTAssert(
      october0050Date == october0050ExpectedDate,
      "Expected the date to be the earliest possible time for the last day of October 0050 BCE.")

    let july06Date = japaneseCalendar.lastDate(
      of: Month(era: 236, year: 06, month: 07, isInGregorianCalendar: false))
    let july06ExpectedDate = japaneseCalendar.date(
      from: DateComponents(era: 236, year: 06, month: 07, day: 31))!
    XCTAssert(
      july06Date == july06ExpectedDate,
      "Expected the date to be the earliest possible time for the last day of July 06.")
  }

  func testMonthByAddingMonths() {
    let june0001BCE = Month(era: 0, year: 0001, month: 06, isInGregorianCalendar: true)
    let january0001CE = Month(era: 1, year: 0001, month: 01, isInGregorianCalendar: true)
    XCTAssert(
      gregorianCalendar.month(byAddingMonths: 7, to: june0001BCE) == january0001CE,
      "Expected June 0001 BCE + 7 = January 0001 CE.")

    let february2020 = Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true)
    let january2019 = Month(era: 1, year: 2019, month: 01, isInGregorianCalendar: true)
    XCTAssert(
      gregorianCalendar.month(byAddingMonths: -13, to: february2020) == january2019,
      "Expected February 2020 - 13 = January 2019.")

    let march02 = Month(era: 236, year: 02, month: 03, isInGregorianCalendar: false)
    let july02 = Month(era: 236, year: 02, month: 07, isInGregorianCalendar: false)
    XCTAssert(
      japaneseCalendar.month(byAddingMonths: 4, to: march02) == july02,
      "Expected March 02 + 4 = July 02.")
  }

  // MARK: Private

  private lazy var gregorianCalendar = Calendar(identifier: .gregorian)
  private lazy var japaneseCalendar = Calendar(identifier: .japanese)

}
