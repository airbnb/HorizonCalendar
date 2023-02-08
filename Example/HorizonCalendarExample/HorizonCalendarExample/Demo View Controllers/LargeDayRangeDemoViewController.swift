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

final class LargeDayRangeDemoViewController: BaseDemoViewController {

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Large Day Range"
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    guard !didScrollToInitialMonth else { return }

    let padding: CGFloat
    switch monthsLayout {
    case .vertical: padding = calendarView.layoutMargins.top
    case .horizontal: padding = calendarView.layoutMargins.left
    }

    let january1500CE = calendar.date(from: DateComponents(era: 1, year: 1500, month: 01, day: 01))!
    calendarView.scroll(
      toMonthContaining: january1500CE,
      scrollPosition: .firstFullyVisiblePosition(padding: padding),
      animated: false)

    didScrollToInitialMonth = true
  }

  override func makeContent() -> CalendarViewContent {
    let startDate = calendar.date(from: DateComponents(era: 0, year: 0100, month: 01, day: 01))!
    let endDate = calendar.date(from: DateComponents(era: 1, year: 2000, month: 12, day: 31))!

    return CalendarViewContent(
      calendar: calendar,
      visibleDateRange: startDate...endDate,
      monthsLayout: monthsLayout)
      .interMonthSpacing(24)
  }

  // MARK: Private

  private var didScrollToInitialMonth = false

}
