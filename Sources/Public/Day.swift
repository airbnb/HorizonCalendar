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

// MARK: - Day

typealias Day = DayComponents

// MARK: - DayComponents

/// Represents the components of a day. This type is created internally, then vended to you via the public API. All `DayComponents`
/// instances that are vended to you are created using the `Calendar` instance that you provide when initializing your
/// `CalendarView`.
public struct DayComponents: Hashable {

  // MARK: Lifecycle

  init(month: MonthComponents, day: Int) {
    self.month = month
    self.day = day
  }

  // MARK: Public

  public let month: MonthComponents
  public let day: Int

  public var components: DateComponents {
    DateComponents(era: month.era, year: month.year, month: month.month, day: day)
  }

}

extension DayComponents {
    public init(from date: Date, calendar: Calendar = Calendar.current) {
        let month = Month(from: date, calendar: calendar)
        let day = calendar.component(.day, from: date)
        self = Day(month: month, day: day)
    }
}

// MARK: CustomStringConvertible

extension DayComponents: CustomStringConvertible {

  public var description: String {
    let yearDescription = String(format: "%04d", month.year)
    let monthDescription = String(format: "%02d", month.month)
    let dayDescription = String(format: "%02d", day)
    return "\(yearDescription)-\(monthDescription)-\(dayDescription)"
  }

}

// MARK: Comparable

extension DayComponents: Comparable {

  public static func < (lhs: DayComponents, rhs: DayComponents) -> Bool {
    guard lhs.month == rhs.month else { return lhs.month < rhs.month }
    return lhs.day < rhs.day
  }

}
