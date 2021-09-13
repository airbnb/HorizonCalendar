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

      if UIAccessibility.isVoiceOverRunning, let selectedDate = self.selectedDate {
        self.calendarView.layoutIfNeeded()
        let accessibilityElementToFocus = self.calendarView.accessibilityElementForVisibleDate(
          selectedDate)
        UIAccessibility.post(notification: .screenChanged, argument: accessibilityElementToFocus)
      }
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

      .withDayItemModelProvider { [calendar, dayDateFormatter] day in
        var invariantViewProperties = DayView.InvariantViewProperties.baseInteractive

        let date = calendar.date(from: day.components)
        if date == selectedDate {
          invariantViewProperties.backgroundShapeDrawingConfig.borderColor = .blue
          invariantViewProperties.backgroundShapeDrawingConfig.fillColor = .blue.withAlphaComponent(0.15)
        }

        return CalendarItemModel<DayView>(
          invariantViewProperties: invariantViewProperties,
          viewModel: .init(
            dayText: "\(day.day)",
            accessibilityLabel: date.map { dayDateFormatter.string(from: $0) },
            accessibilityHint: nil))
      }
  }

  // MARK: Private

  private var selectedDate: Date?

}

