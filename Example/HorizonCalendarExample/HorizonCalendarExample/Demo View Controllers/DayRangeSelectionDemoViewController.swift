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

final class DayRangeSelectionDemoViewController: BaseDemoViewController {

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Day Range Selection"

    calendarView.daySelectionHandler = { [weak self] day in
      guard let self else { return }

      DayRangeSelectionHelper.updateDayRange(
        afterTapSelectionOf: day,
        existingDayRange: &selectedDayRange)

      calendarView.setContent(makeContent())
    }

    calendarView.multiDaySelectionDragHandler = { [weak self, calendar] day, state in
      guard let self else { return }

      DayRangeSelectionHelper.updateDayRange(
        afterDragSelectionOf: day,
        existingDayRange: &selectedDayRange,
        initialDayRange: &selectedDayRangeAtStartOfDrag,
        state: state,
        calendar: calendar)

      calendarView.setContent(makeContent())
    }
  }

  override func makeContent() -> CalendarViewContent {
    let startDate = calendar.date(from: DateComponents(year: 2020, month: 01, day: 01))!
    let endDate = calendar.date(from: DateComponents(year: 2021, month: 12, day: 31))!

    let dateRanges: Set<ClosedRange<Date>>
    let selectedDayRange = selectedDayRange
    if
      let selectedDayRange,
      let lowerBound = calendar.date(from: selectedDayRange.lowerBound.components),
      let upperBound = calendar.date(from: selectedDayRange.upperBound.components)
    {
      dateRanges = [lowerBound...upperBound]
    } else {
      dateRanges = []
    }

    return CalendarViewContent(
      calendar: calendar,
      visibleDateRange: startDate...endDate,
      monthsLayout: monthsLayout)

      .interMonthSpacing(24)
      .verticalDayMargin(8)
      .horizontalDayMargin(8)

      .dayItemProvider { [calendar, dayDateFormatter] day in
        var invariantViewProperties = DayView.InvariantViewProperties.baseInteractive

        let isSelectedStyle: Bool
        if let selectedDayRange {
          isSelectedStyle = day == selectedDayRange.lowerBound || day == selectedDayRange.upperBound
        } else {
          isSelectedStyle = false
        }

        if isSelectedStyle {
          invariantViewProperties.backgroundShapeDrawingConfig.fillColor = .systemBackground
          invariantViewProperties.backgroundShapeDrawingConfig.borderColor = UIColor(.accentColor)
        }

        let date = calendar.date(from: day.components)

        return DayView.calendarItemModel(
          invariantViewProperties: invariantViewProperties,
          content: .init(
            dayText: "\(day.day)",
            accessibilityLabel: date.map { dayDateFormatter.string(from: $0) },
            accessibilityHint: nil))
      }

      .dayRangeItemProvider(for: dateRanges) { dayRangeLayoutContext in
        DayRangeIndicatorView.calendarItemModel(
          invariantViewProperties: .init(),
          content: .init(
            framesOfDaysToHighlight: dayRangeLayoutContext.daysAndFrames.map { $0.frame }))
      }
  }

  // MARK: Private

  private var selectedDayRange: DayComponentsRange?
  private var selectedDayRangeAtStartOfDrag: DayComponentsRange?

}
