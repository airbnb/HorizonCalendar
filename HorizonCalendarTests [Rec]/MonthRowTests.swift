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

// MARK: - MonthRowTests

final class MonthRowTests: XCTestCase {

  // MARK: Internal

  func testRowInMonthForDate() {
    let date0 = gregorianCalendar.date(from: DateComponents(year: 2020, month: 06, day: 02))!
    XCTAssert(
      gregorianCalendar.rowInMonth(for: date0) == 0,
      "Expected June 2, 2020 to be in the first row of the month.")

    let date1 = gregorianCalendar.date(from: DateComponents(year: 2020, month: 02, day: 05))!
    XCTAssert(
      gregorianCalendar.rowInMonth(for: date1) == 1,
      "Expected February 5, 2020 to be in the second row of the month.")

    let date2 = gregorianCalendar.date(from: DateComponents(year: 1500, month: 12, day: 15))!
    XCTAssert(
      gregorianCalendar.rowInMonth(for: date2) == 2,
      "Expected December 15, 1500 to be in the third row of the month.")

    let date3 = gregorianCalendar.date(from: DateComponents(year: 0001, month: 02, day: 21))!
    XCTAssert(
      gregorianCalendar.rowInMonth(for: date3) == 3,
      "Expected February 21, 0001 CE to be in the fourth row of the month.")

    let date4 = gregorianCalendar.date(from: DateComponents(year: 2020, month: 06, day: 30))!
    XCTAssert(
      gregorianCalendar.rowInMonth(for: date4) == 4,
      "Expected June 30, 2020 to be in the fifth row of the month.")

    let date5 = gregorianCalendar.date(from: DateComponents(year: 2020, month: 05, day: 31))!
    XCTAssert(
      gregorianCalendar.rowInMonth(for: date5) == 5,
      "Expected May 31, 2020 to be in the sixth row of the month.")

    let date6 = japaneseCalendar.date(from: DateComponents(era: 236, year: 01, month: 03, day: 01))!
    XCTAssert(
      japaneseCalendar.rowInMonth(for: date6) == 0,
      "Expected March 1, 01 era 236 to be in the first row of the month.")

    let date7 = japaneseCalendar.date(from: DateComponents(era: 236, year: 01, month: 03, day: 31))!
    XCTAssert(
      japaneseCalendar.rowInMonth(for: date7) == 5,
      "Expected March 31, 01 era 236 to be in the sixth row of the month.")
  }

  // MARK: Private

  private lazy var gregorianCalendar = Calendar(identifier: .gregorian)
  private lazy var japaneseCalendar = Calendar(identifier: .japanese)

}
