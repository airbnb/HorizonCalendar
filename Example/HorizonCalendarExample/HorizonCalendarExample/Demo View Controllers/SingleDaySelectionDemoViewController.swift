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

import HorizonCalendar
import UIKit

final class SingleDaySelectionDemoViewController: DemoViewController {

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Single Day Selection"

    calendarView.daySelectionHandler = { [weak self] day in
      guard let self = self else { return }

      self.selectedDay = day
      self.calendarView.setContent(self.makeContent())
    }
  }

  override func makeContent() -> CalendarViewContent {
    let startDate = calendar.date(from: DateComponents(year: 2020, month: 01, day: 01))!
    let endDate = calendar.date(from: DateComponents(year: 2021, month: 12, day: 31))!

    let selectedDay = self.selectedDay

    return CalendarViewContent(
      calendar: calendar,
      visibleDateRange: startDate...endDate,
      monthsLayout: monthsLayout)

      .withInterMonthSpacing(24)
      .withVerticalDayMargin(8)
      .withHorizontalDayMargin(8)

      .withDayItemModelProvider { [weak self] day in
        let textColor: UIColor
        if #available(iOS 13.0, *) {
          textColor = .label
        } else {
          textColor = .black
        }

        let dayAccessibilityText: String?
        if let date = self?.calendar.date(from: day.components) {
          dayAccessibilityText = self?.dayDateFormatter.string(from: date)
        } else {
          dayAccessibilityText = nil
        }

        return CalendarItemModel<DayView>(
          invariantViewProperties: .init(textColor: textColor, isSelectedStyle: day == selectedDay),
          viewModel: .init(dayText: "\(day.day)", dayAccessibilityText: dayAccessibilityText))
      }
  }

  // MARK: Private

  private var selectedDay: Day?

}
