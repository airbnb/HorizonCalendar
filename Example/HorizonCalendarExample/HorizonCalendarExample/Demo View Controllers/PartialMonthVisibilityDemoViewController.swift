// Created by Bryan Keller on 6/23/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import HorizonCalendar
import UIKit

final class PartialMonthVisibilityDemoViewController: DemoViewController {

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Partial Month Visibility"

    calendarView.daySelectionHandler = { [weak self] day in
      guard let self = self else { return }

      self.selectedDate = self.calendar.date(from: day.components)
      self.calendarView.setContent(self.makeContent())
    }
  }

  override func makeContent() -> CalendarViewContent {
    let startDate = calendar.date(from: DateComponents(year: 2020, month: 01, day: 16))!
    let endDate = calendar.date(from: DateComponents(year: 2020, month: 12, day: 05))!

    let selectedDate = self.selectedDate

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

        let isSelectedStyle: Bool
        let dayAccessibilityText: String?
        if let date = self?.calendar.date(from: day.components) {
          isSelectedStyle = selectedDate == date
          dayAccessibilityText = self?.dayDateFormatter.string(from: date)
        } else {
          isSelectedStyle = false
          dayAccessibilityText = nil
        }

        return CalendarItemModel<DayView>(
          invariantViewProperties: .init(textColor: textColor, isSelectedStyle: isSelectedStyle),
          viewModel: .init(dayText: "\(day.day)", dayAccessibilityText: dayAccessibilityText))
      }
  }

  // MARK: Private

  private var selectedDate: Date?

}

