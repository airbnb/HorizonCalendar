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

// MARK: Month Helpers

extension Calendar {

  func month(containing date: Date) -> Month {
    return Month(
      era: component(.era, from: date),
      year: component(.year, from: date),
      month: component(.month, from: date),
      isInGregorianCalendar: identifier == .gregorian)
  }

  func firstDate(of month: Month) -> Date {
    let firstDateComponents = DateComponents(era: month.era, year: month.year, month: month.month)
    guard let firstDate = date(from: firstDateComponents) else {
      preconditionFailure("Failed to create a `Date` representing the first day of \(month).")
    }

    return firstDate
  }

  func lastDate(of month: Month) -> Date {
    let firstDate = self.firstDate(of: month)
    guard let numberOfDaysInMonth = range(of: .day, in: .month, for: firstDate)?.count else {
      preconditionFailure("Could not get number of days in month from \(firstDate).")
    }

    let lastDateComponents = DateComponents(
      era: month.era,
      year: month.year,
      month: month.month,
      day: numberOfDaysInMonth)
    guard let lastDate = date(from: lastDateComponents) else {
      preconditionFailure("Failed to create a `Date` representing the last day of \(month).")
    }

    return lastDate
  }

  func month(byAddingMonths numberOfMonths: Int, to month: Month) -> Month {
    guard
      let firstDateOfNextMonth = date(
        byAdding: .month,
        value: numberOfMonths,
        to: firstDate(of: month))
    else
    {
      preconditionFailure("Failed to advance \(month) by \(numberOfMonths) months.")
    }

    return self.month(containing: firstDateOfNextMonth)
  }

}

// MARK: Day Helpers

extension Calendar {

  func day(containing date: Date) -> Day {
    let month = Month(
      era: component(.era, from: date),
      year: component(.year, from: date),
      month: component(.month, from: date),
      isInGregorianCalendar: identifier == .gregorian)
    return Day(month: month, day: component(.day, from: date))
  }

  func startDate(of day: Day) -> Date {
    let dateComponents = DateComponents(
      era: day.month.era,
      year: day.month.year,
      month: day.month.month,
      day: day.day)
    guard let date = date(from: dateComponents) else {
      preconditionFailure("Failed to create a `Date` representing the start of \(day).")
    }

    return date
  }

  func day(byAddingDays numberOfDays: Int, to day: Day) -> Day {
    guard
      let firstDateOfNextDay = date(byAdding: .day, value: numberOfDays, to: startDate(of: day))
    else
    {
      preconditionFailure("Failed to advance \(day) by \(numberOfDays) days.")
    }

    return self.day(containing: firstDateOfNextDay)
  }

}

// MARK: Day of Week Helpers

extension Calendar {

  func dayOfWeekPosition(for date: Date) -> DayOfWeekPosition {
    let weekdayComponent = component(.weekday, from: date)
    let distanceFromFirstWeekday = firstWeekday - weekdayComponent

    let numberOfPositions = DayOfWeekPosition.numberOfPositions
    let weekdayIndex = (numberOfPositions - distanceFromFirstWeekday) % numberOfPositions

    guard let dayOfWeekPosition = DayOfWeekPosition(rawValue: weekdayIndex + 1) else {
      preconditionFailure("""
        Could not find a day of the week position for date \(date) in calendar \(self).
      """)
    }

    return dayOfWeekPosition
  }

  func weekdayIndex(for dayOfWeekPosition: DayOfWeekPosition) -> Int {
    let indexOfFirstWeekday = firstWeekday - 1
    let numberOfWeekdays = DayOfWeekPosition.numberOfPositions
    let weekdayIndex = (indexOfFirstWeekday + (dayOfWeekPosition.rawValue - 1)) % numberOfWeekdays
    return weekdayIndex
  }

}

// MARK: Month Row Helpers

extension Calendar {

  // Some locales have a minimum number of days requirement for a date to be considered in the first
  // week. To abstract away this complexity and simplify the layout of "weeks," we do all layout
  // calculations based on a date's "row" in a month (which may or not map to a week, depending on
  // the minimum days requirement for the first week in some locales).
  func rowInMonth(for date: Date) -> Int {
    let firstDateOfMonth = firstDate(
      of: Month(
        era: component(.era, from: date),
        year: component(.year, from: date),
        month: component(.month, from: date),
        isInGregorianCalendar: identifier == .gregorian))

    let numberOfPositions = DayOfWeekPosition.numberOfPositions
    let dayOfWeekPosition = self.dayOfWeekPosition(for: firstDateOfMonth)
    let daysFromEndOfWeek = numberOfPositions - (dayOfWeekPosition.rawValue - 1)
    let isFirstDayInFirstWeek = daysFromEndOfWeek >= minimumDaysInFirstWeek

    if isFirstDayInFirstWeek {
      return component(.weekOfMonth, from: date) - 1
    } else {
      return component(.weekOfMonth, from: date)
    }
  }

}
