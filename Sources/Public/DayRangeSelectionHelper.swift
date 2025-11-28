// Created by Bryan Keller on 2/8/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

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

public enum DayRangeSelectionHelper {

    /// - Description: Check all dates in the new range and update the range if there are no blacked out dates.
    /// - Parameters:
    ///   - day: The day object selected by the user
    ///   - dayRange: Current range selected by user
    ///   - calendar: The calendar to calculate dates with
    /// - Returns: A set of blacked out dates
    @discardableResult
    public static func getInvalidDateSet(_ day: Day,
                                         _ dayRange: DayComponentsRange?,
                                         _ calendar: Calendar) -> Set<Date> {
        var invalidDates: Set<Date> = []

        guard var dayRange else { return invalidDates }

        var newRange: ClosedRange<Day>?

        performUpdateRangeHelper(day, &newRange, &dayRange, calendar)

        var currentDate = calendar.date(from: newRange!.lowerBound.components)!
        let endDate = calendar.date(from: newRange!.upperBound.components)!

        while currentDate <= endDate {
            let isEnabled = Day.availabilityProvider?.isEnabled(currentDate) ?? true

            if !isEnabled {
                invalidDates.insert(currentDate)
            }

            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return invalidDates
    }

    /// - Description: Update the day range, if it is a valid selection. If the day slected is blacked out, the
    /// range will not change. If the day selected generates a range which contains blacked out days, the range
    /// will be the selected day.
    /// - Parameters:
    ///   - afterTapSelectionOf: The day selected by the user
    ///   - existingDayRange: The range to be updated
    /// - Returns: The set of invalid dates. Empty represents no invalid dates.
    @discardableResult
    public static func updateDayRange(afterTapSelectionOf day: Day,
                                      existingDayRange: inout DayComponentsRange?) -> Set<Date> {
        if day.isEnabled {
            if let dayRange = existingDayRange,
                dayRange.lowerBound == dayRange.upperBound,
                day > dayRange.lowerBound {
                // Ensure date range is valid only if it will not create single-node range
                let invalidRange = getInvalidDateSet(day, existingDayRange, Calendar.current)
                guard invalidRange.isEmpty else {
                    existingDayRange = day...day
                    return invalidRange
                }

                existingDayRange = dayRange.lowerBound...day
            } else {
                existingDayRange = day...day
            }
        }

        return []
    }

    /// - Description: An assistant to the performUpdateRange function. Will create a range from the lower or
    /// upper bound to the selected day, based on the nearest distance.
    /// - SeeAlso: performUpdateRange(\_:\_:\_:\_:)
    /// - Parameters:
    ///   - day: The day selected by the user
    ///   - existingDayRange: The range to be returned
    ///   - initalDayRange: The range prior to user selection
    ///   - calendar: The calendar to calculate days on
    private static func performUpdateRangeHelper(_ day: Day,
                                                 _ existingDayRange: inout ClosedRange<Day>?,
                                                 _ initialDayRange: inout ClosedRange<Day>,
                                                 _ calendar: Calendar) {

        let startingLowerDate = calendar.date(from: initialDayRange.lowerBound.components)!
        let startingUpperDate = calendar.date(from: initialDayRange.upperBound.components)!
        let selectedDate = calendar.date(from: day.components)!

        let numberOfDaysToLowerDate = calendar
            .dateComponents([.day],
                            from: selectedDate,
                            to: startingLowerDate).day!
        let numberOfDaysToUpperDate = calendar
            .dateComponents([.day],
                            from: selectedDate,
                            to: startingUpperDate).day!

        if abs(numberOfDaysToLowerDate) < abs(numberOfDaysToUpperDate) ||
                day < initialDayRange.lowerBound {

            existingDayRange = day...initialDayRange.upperBound

        } else if abs(numberOfDaysToLowerDate) > abs(numberOfDaysToUpperDate) ||
                    day > initialDayRange.upperBound {

            existingDayRange = initialDayRange.lowerBound...day
        } else {
            existingDayRange = day...day
        }
    }

    /// - Description: Will create a range from the lower or upper bound to the selected day, based on the nearest
    /// distance.
    /// - SeeAlso: performUpdateRangeHelper(\_:\_:\_:\_:)
    /// - Parameters:
    ///   - day: The day selected by the user
    ///   - existingDayRange: The range to be returned
    ///   - initalDayRange: The range prior to user selection
    ///   - calendar: The calendar to calculate days on
    public static func performUpdateRange(_ day: Day,
                                          _ existingDayRange: inout ClosedRange<Day>?,
                                          _ initialDayRange: inout ClosedRange<Day>?,
                                          _ calendar: Calendar) {
        performUpdateRangeHelper(day, &existingDayRange, &((initialDayRange)!), calendar)
    }
}
