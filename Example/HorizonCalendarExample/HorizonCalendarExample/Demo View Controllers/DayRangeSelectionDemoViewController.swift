// Created by Bryan Keller on 6/18/20.
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

import HorizonCalendar
import UIKit

final class DayRangeSelectionDemoViewController: DemoViewController {

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Day Range Selection"

    calendarView.daySelectionHandler = { [weak self] day in
      guard let self = self else { return }

      switch self.calendarSelection {
      case .singleDay(let selectedDay):
        if day > selectedDay {
          self.calendarSelection = .dayRange(selectedDay...day)
        } else {
          self.calendarSelection = .singleDay(day)
        }
      case .none, .dayRange:
        self.calendarSelection = .singleDay(day)
      }

      self.calendarView.setContent(self.makeContent())

      if
        UIAccessibility.isVoiceOverRunning,
        let selectedDate = self.calendar.date(from: day.components)
      {
        self.calendarView.layoutIfNeeded()
        let accessibilityElementToFocus = self.calendarView.accessibilityElementForVisibleDate(
          selectedDate)
        UIAccessibility.post(notification: .screenChanged, argument: accessibilityElementToFocus)
      }
    }
  }

  override func makeContent() -> CalendarViewContent {
    let startDate = calendar.date(from: DateComponents(year: 2020, month: 01, day: 01))!
    let endDate = calendar.date(from: DateComponents(year: 2021, month: 12, day: 31))!

    let calendarSelection = self.calendarSelection
    let dateRanges: Set<ClosedRange<Date>>
    if
      case .dayRange(let dayRange) = calendarSelection,
      let lowerBound = calendar.date(from: dayRange.lowerBound.components),
      let upperBound = calendar.date(from: dayRange.upperBound.components)
    {
      dateRanges = [lowerBound...upperBound]
    } else {
      dateRanges = []
    }

    return CalendarViewContent(
      calendar: calendar,
      visibleDateRange: startDate...endDate,
      monthsLayout: monthsLayout)

      .withInterMonthSpacing(24)
      .withVerticalDayMargin(8)
      .withHorizontalDayMargin(8)

      .withDayItemModelProvider { [calendar, dayDateFormatter] day in
        var invariantViewProperties = DayView.InvariantViewProperties.baseInteractive

        let isSelectedStyle: Bool
        switch calendarSelection {
        case .singleDay(let selectedDay):
          isSelectedStyle = day == selectedDay
        case .dayRange(let selectedDayRange):
          isSelectedStyle = day == selectedDayRange.lowerBound || day == selectedDayRange.upperBound
        case .none:
          isSelectedStyle = false
        }

        if isSelectedStyle {
          invariantViewProperties.backgroundShapeDrawingConfig.borderColor = .blue
        }

        let date = calendar.date(from: day.components)

        return CalendarItemModel<DayView>(
          invariantViewProperties: invariantViewProperties,
          viewModel: .init(
            dayText: "\(day.day)",
            accessibilityLabel: date.map { dayDateFormatter.string(from: $0) },
            accessibilityHint: nil))
      }

      .withDayRangeItemModelProvider(for: dateRanges) { dayRangeLayoutContext in
        CalendarItemModel<DayRangeIndicatorView>(
          invariantViewProperties: .init(),
          viewModel: .init(
            framesOfDaysToHighlight: dayRangeLayoutContext.daysAndFrames.map { $0.frame }))
      }
  }

  // MARK: Private

  private enum CalendarSelection {
    case singleDay(Day)
    case dayRange(DayRange)
  }
  private var calendarSelection: CalendarSelection?

}
