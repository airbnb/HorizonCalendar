// Created by Bryan Keller on 5/31/20.
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

import Foundation

// MARK: - Month

typealias Month = MonthComponents

// MARK: - MonthComponents

/// Represents the components of a month. This type is created internally, then vended to you via the public API. All
/// `MonthComponents` instances that are vended to you are created using the `Calendar` instance that you provide when
/// initializing your `CalendarView`.
public struct MonthComponents: Hashable {

  // MARK: Lifecycle

  init(era: Int, year: Int, month: Int, isInGregorianCalendar: Bool) {
    self.era = era
    self.year = year
    self.month = month
    self.isInGregorianCalendar = isInGregorianCalendar
  }

  // MARK: Public

  public let era: Int
  public let year: Int
  public let month: Int

  public var components: DateComponents {
    DateComponents(era: era, year: year, month: month)
  }

  // MARK: Internal

  // In the Gregorian calendar, BCE years (era 0) get larger in descending order (10 BCE < 5 BCE).
  // This property exists to facilitate an accurate `Comparable` implementation.
  let isInGregorianCalendar: Bool

}

extension MonthComponents {
    public init(from date: Date, calendar: Calendar = Calendar.current) {
     self = calendar.month(containing: date)
  }
}

// MARK: CustomStringConvertible

extension MonthComponents: CustomStringConvertible {

  public var description: String {
    "\(String(format: "%04d", year))-\(String(format: "%02d", month))"
  }

}

// MARK: Comparable

extension MonthComponents: Comparable {

  public static func < (lhs: MonthComponents, rhs: MonthComponents) -> Bool {
    guard lhs.era == rhs.era else { return lhs.era < rhs.era }

    let lhsCorrectedYear = lhs.isInGregorianCalendar && lhs.era == 0 ? -lhs.year : lhs.year
    let rhsCorrectedYear = rhs.isInGregorianCalendar && rhs.era == 0 ? -rhs.year : rhs.year
    guard lhsCorrectedYear == rhsCorrectedYear else { return lhsCorrectedYear < rhsCorrectedYear }

    return lhs.month < rhs.month
  }

}
