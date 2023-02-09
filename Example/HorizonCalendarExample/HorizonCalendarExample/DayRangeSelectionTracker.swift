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

import HorizonCalendar
import UIKit

enum DayRangeSelectionHelper {

  static func updateDayRange(afterTapSelectionOf day: Day, existingDayRange: inout DayRange?) {
    if
      let _existingDayRange = existingDayRange,
      _existingDayRange.lowerBound == _existingDayRange.upperBound,
      day > _existingDayRange.lowerBound
    {
      existingDayRange = _existingDayRange.lowerBound...day
    } else {
      existingDayRange = day...day
    }
  }

  static func updateDayRange(
    afterDragSelectionOf day: Day,
    existingDayRange: inout DayRange?,
    initialDayRange: inout DayRange?,
    state: UIGestureRecognizer.State,
    calendar: Calendar)
  {
    switch state {
    case .began:
      if day != existingDayRange?.lowerBound && day != existingDayRange?.upperBound {
        existingDayRange = day...day
      }
      initialDayRange = existingDayRange

    case .changed, .ended:
      guard let initialDayRange else {
        fatalError("`initialDayRange` should not be `nil`")
      }

      let startingLowerDate = calendar.date(from: initialDayRange.lowerBound.components)!
      let startingUpperDate = calendar.date(from: initialDayRange.upperBound.components)!
      let selectedDate = calendar.date(from: day.components)!

      let numberOfDaysToLowerDate = calendar.dateComponents(
        [.day],
        from: selectedDate,
        to: startingLowerDate).day!
      let numberOfDaysToUpperDate = calendar.dateComponents(
        [.day],
        from: selectedDate,
        to: startingUpperDate).day!

      if
        abs(numberOfDaysToLowerDate) < abs(numberOfDaysToUpperDate) ||
        day < initialDayRange.lowerBound
      {
        existingDayRange = day...initialDayRange.upperBound
      } else if
        abs(numberOfDaysToLowerDate) > abs(numberOfDaysToUpperDate) ||
        day > initialDayRange.upperBound
      {
        existingDayRange = initialDayRange.lowerBound...day
      }

    default:
      existingDayRange = nil
      initialDayRange = nil
    }
  }

}
