// Created by Bryan Keller on 8/23/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

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
import SwiftUI

final class SwiftUIItemModelsDemoViewController: BaseDemoViewController {

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "SwiftUI Day and Month Views"

    calendarView.daySelectionHandler = { [weak self] day in
      guard let self else { return }

      self.selectedDate = self.calendar.date(from: day.components)
      self.calendarView.setContent(self.makeContent())
    }
  }

  override func makeContent() -> CalendarViewContent {
    let startDate = calendar.date(from: DateComponents(year: 2020, month: 01, day: 01))!
    let endDate = calendar.date(from: DateComponents(year: 2021, month: 12, day: 31))!

    let selectedDate = self.selectedDate

    return CalendarViewContent(
      calendar: calendar,
      visibleDateRange: startDate...endDate,
      monthsLayout: monthsLayout)

      .interMonthSpacing(24)
      .verticalDayMargin(8)
      .horizontalDayMargin(8)

      .monthHeaderItemProvider { [calendar, monthDateFormatter] month in
        guard let firstDateInMonth = calendar.date(from: month.components) else {
          preconditionFailure("Could not find a date corresponding to the month \(month).")
        }
        let monthText = monthDateFormatter.string(from: firstDateInMonth)
        return HStack {
          Text(monthText).font(.headline)
          Spacer()
        }
        .padding(.vertical)
        .calendarItemModel
      }

      .dayItemProvider { [calendar, selectedDate] day in
        let date = calendar.date(from: day.components)
        let isSelected = date == selectedDate
        return SwiftUIDayView(dayNumber: day.day, isSelected: isSelected).calendarItemModel
      }
  }

  // MARK: Private

  private lazy var monthDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.calendar = calendar
    dateFormatter.locale = calendar.locale
    dateFormatter.dateFormat = DateFormatter.dateFormat(
      fromTemplate: "MMMM yyyy",
      options: 0,
      locale: calendar.locale ?? Locale.current)
    return dateFormatter
  }()

  private var selectedDate: Date?

}
