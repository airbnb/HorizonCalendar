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

// MARK: - ScrollToDayWithAnimationDemoViewController

final class ScrollToDayWithAnimationDemoViewController: UIViewController, DemoViewController {

  // MARK: Lifecycle

  init(monthsLayout: MonthsLayout) {
    self.monthsLayout = monthsLayout
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Scroll to Day with Animation"

    if #available(iOS 13.0, *) {
      view.backgroundColor = .systemBackground
    } else {
      view.backgroundColor = .white
    }

    view.addSubview(calendarView)

    calendarView.translatesAutoresizingMaskIntoConstraints = false
    switch monthsLayout {
    case .vertical:
      NSLayoutConstraint.activate([
        calendarView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
        calendarView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
        calendarView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
        calendarView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
      ])
    case .horizontal(let monthWidth):
      NSLayoutConstraint.activate([
        calendarView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        calendarView.heightAnchor.constraint(equalToConstant: monthWidth * 1.5),
        calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      ])
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    let july2020 = calendar.date(from: DateComponents(year: 2020, month: 07, day: 11))!
    calendarView.scroll(
      toDayContaining: july2020,
      scrollPosition: .centered,
      animated: true)
  }

  // MARK: Private

  private let monthsLayout: MonthsLayout

  private lazy var calendarView = CalendarView(initialContent: makeContent())
  private lazy var calendar = Calendar(identifier: .gregorian)

  private func makeContent() -> CalendarViewContent {
    let startDate = calendar.date(from: DateComponents(year: 2016, month: 07, day: 11))!
    let endDate = calendar.date(from: DateComponents(year: 2020, month: 12, day: 31))!

    return CalendarViewContent(
      calendar: calendar,
      visibleDateRange: startDate...endDate,
      monthsLayout: monthsLayout)
  }

}
