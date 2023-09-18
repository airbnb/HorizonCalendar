// Created by Bryan Keller on 1/30/23.
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

final class MonthBackgroundDemoViewController: BaseDemoViewController {

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Month Grid Background"
  }

  override func makeContent() -> CalendarViewContent {
    let startDate = calendar.date(from: DateComponents(year: 2020, month: 01, day: 01))!
    let endDate = calendar.date(from: DateComponents(year: 2021, month: 12, day: 31))!

    return CalendarViewContent(
      calendar: calendar,
      visibleDateRange: startDate...endDate,
      monthsLayout: monthsLayout)

      .interMonthSpacing(24)
      .verticalDayMargin(8)
      .horizontalDayMargin(8)

      .monthBackgroundItemProvider { monthLayoutContext in
        MonthGridBackgroundView.calendarItemModel(
          invariantViewProperties: .init(horizontalDayMargin: 8, verticalDayMargin: 8),
          content: .init(framesOfDays: monthLayoutContext.daysAndFrames.map { $0.frame }))
      }
  }

  // MARK: Private

  private var selectedDate: Date?

}
