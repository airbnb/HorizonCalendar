// Created by Bryan Keller on 4/20/20.
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

// MARK: - MonthTests

final class MonthTests: XCTestCase {

  // MARK: Internal

  // MARK: - Advancing Months Tests

  func testAdvancingByNothing() {
    let month = calendar.month(
      byAddingMonths: 0,
      to: Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true))
    XCTAssert(month == Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true), "Expected 2020-01.")
  }

  func testAdvancingByLessThanOneYear() {
    let month1 = calendar.month(
      byAddingMonths: 4,
      to: Month(era: 1, year: 2020, month: 06, isInGregorianCalendar: true))
    XCTAssert(month1 == Month(era: 1, year: 2020, month: 10, isInGregorianCalendar: true), "Expected 2020-10.")

    let month2 = calendar.month(
      byAddingMonths: -4,
      to: Month(era: 1, year: 2020, month: 06, isInGregorianCalendar: true))
    XCTAssert(month2 == Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true), "Expected 2020-02.")
  }

  func testAdvancingByMoreThanOneYear() {
    let month1 = calendar.month(
      byAddingMonths: 16,
      to: Month(era: 1, year: 2020, month: 08, isInGregorianCalendar: true))
    XCTAssert(month1 == Month(era: 1, year: 2021, month: 12, isInGregorianCalendar: true), "Expected 2021-12.")

    let month2 = calendar.month(
      byAddingMonths: -25,
      to: Month(era: 1, year: 2020, month: 06, isInGregorianCalendar: true))
    XCTAssert(month2 == Month(era: 1, year: 2018, month: 05, isInGregorianCalendar: true), "Expected 2018-05.")
  }

  // MARK: Private

  private let calendar = Calendar(identifier: .gregorian)

}
