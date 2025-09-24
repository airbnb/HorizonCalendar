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

final class ScrollToDayWithAnimationDemoViewController: BaseDemoViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Scroll to Day with Animation"
    
    // Add a Today button in the navigation bar
    let todayButton = UIBarButtonItem(
      title: "Today",
      style: .plain,
      target: self,
      action: #selector(scrollToToday))
    navigationItem.rightBarButtonItem = todayButton
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    let july2020 = calendar.date(from: DateComponents(year: 2020, month: 07, day: 11))!
    calendarView.scrollToToday()
  }
  
  @objc private func scrollToToday() {
    calendarView.scrollToToday()
  }

  override func makeContent() -> CalendarViewContent {
    let startDate = calendar.date(from: DateComponents(year: 2016, month: 07, day: 01))!
    let endDate = calendar.date(from: DateComponents(year: 2027, month: 12, day: 31))!

    return CalendarViewContent(
      calendar: calendar,
      visibleDateRange: startDate...endDate,
      monthsLayout: monthsLayout)
      .interMonthSpacing(24)
  }
}
