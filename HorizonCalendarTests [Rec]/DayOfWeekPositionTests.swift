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

// MARK: - DayOfWeekPositionTests

final class DayOfWeekPositionTests: XCTestCase {

  // MARK: Internal

  func testWeekdayIndex() throws {
    let allPositions = DayOfWeekPosition.allCases
    for (position, expectedWeekdayIndex) in zip(allPositions, 0...6) {
      XCTAssert(
        gregorianCalendar.weekdayIndex(for: position) == expectedWeekdayIndex,
        "Expected \(position) of the week to have weekday index = \(expectedWeekdayIndex).")
    }

    for (position, expectedWeekdayIndex) in zip(allPositions, [1, 2, 3, 4, 5, 6, 0]) {
      XCTAssert(
        gregorianUKCalendar.weekdayIndex(for: position) == expectedWeekdayIndex,
        "Expected \(position) of the week to have weekday index = \(expectedWeekdayIndex).")
    }
  }

  func testDayOfWeekComparable() {
    for dayOfWeekPositionRawValue in DayOfWeekPosition.allCases.map({ $0.rawValue }) {
      if dayOfWeekPositionRawValue > 1 {
        let dayOfWeekPosition = DayOfWeekPosition(rawValue: dayOfWeekPositionRawValue)!
        let previousDayOfWeekPosition = DayOfWeekPosition(rawValue: dayOfWeekPositionRawValue - 1)!
        XCTAssert(
          previousDayOfWeekPosition < dayOfWeekPosition,
          "Expected \(previousDayOfWeekPosition) < \(dayOfWeekPosition).")
      }
    }
  }

  func testDayOfWeekPositionForDate() {
    let date0 = gregorianCalendar.date(from: DateComponents(year: 2020, month: 01, day: 19))!
    XCTAssert(
      gregorianCalendar.dayOfWeekPosition(for: date0) == .first,
      "Expected January 19, 2020 to fall on the first day of the week.")

    let date1 = gregorianCalendar.date(from: DateComponents(year: 2015, month: 05, day: 01))!
    XCTAssert(
      gregorianCalendar.dayOfWeekPosition(for: date1) == .sixth,
      "Expected May 1, 2015 to fall on the sixth day of the week.")

    let date2 = japaneseCalendar.date(from: DateComponents(era: 236, year: 01, month: 12, day: 25))!
    XCTAssert(
      japaneseCalendar.dayOfWeekPosition(for: date2) == .fourth,
      "Expected December 25, 01 era 236 to fall on the fourth day of the week.")

    let date3 = japaneseCalendar.date(from: DateComponents(era: 235, year: 30, month: 07, day: 10))!
    XCTAssert(
      japaneseCalendar.dayOfWeekPosition(for: date3) == .third,
      "Expected July 10, 30 era 235 to fall on the third day of the week.")

    let date4 = gregorianCalendar.date(from: DateComponents(year: 2100, month: 04, day: 22))!
    XCTAssert(
      gregorianCalendar.dayOfWeekPosition(for: date4) == .fifth,
      "Expected April 22, 2100 to fall on the fifth day of the week.")

    let date5 = gregorianCalendar.date(
      from: DateComponents(era: 0, year: 0018, month: 01, day: 03))!
    XCTAssert(
      gregorianCalendar.dayOfWeekPosition(for: date5) == .last,
      "Expected March 1, 0016 BCE to fall on the last day of the week.")

    let date6 = gregorianCalendar.date(
      from: DateComponents(era: 0, year: 1492, month: 09, day: 22))!
    XCTAssert(
      gregorianCalendar.dayOfWeekPosition(for: date6) == .second,
      "Expected September 19, 1492 to fall on the second day of the week.")
  }

  // MARK: Private

  private lazy var gregorianCalendar = Calendar(identifier: .gregorian)
  private lazy var japaneseCalendar = Calendar(identifier: .japanese)
  private lazy var gregorianUKCalendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.locale = Locale(identifier: "en_GB")
    return calendar
  }()

}
