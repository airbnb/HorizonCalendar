// Created by Bryan Keller on 6/23/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import HorizonCalendar
import UIKit

// MARK: - PartialMonthVisibilityDemoViewController

final class PartialMonthVisibilityDemoViewController: UIViewController, DemoViewController {

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

    title = "Partial Month Visibility"

    if #available(iOS 13.0, *) {
      view.backgroundColor = .systemBackground
    } else {
      view.backgroundColor = .white
    }

    calendarView.daySelectionHandler = { [weak self] day in
      guard let self = self else { return }

      self.selectedDay = day
      self.calendarView.setContent(self.makeContent())
    }
    view.addSubview(calendarView)

    calendarView.translatesAutoresizingMaskIntoConstraints = false
    switch monthsLayout {
    case .vertical:
      NSLayoutConstraint.activate([
        calendarView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
        calendarView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
        calendarView.leadingAnchor.constraint(
          greaterThanOrEqualTo: view.layoutMarginsGuide.leadingAnchor),
        calendarView.trailingAnchor.constraint(
          lessThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor),
        calendarView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        calendarView.widthAnchor.constraint(lessThanOrEqualToConstant: 375)
      ])
    case .horizontal(let monthWidth):
      NSLayoutConstraint.activate([
        calendarView.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),
        calendarView.heightAnchor.constraint(equalToConstant: monthWidth * 1.1),
        calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      ])
    }
  }

  // MARK: Private

  private let monthsLayout: MonthsLayout

  private lazy var calendarView = CalendarView(initialContent: makeContent())
  private lazy var calendar = Calendar(identifier: .gregorian)
  private lazy var dayDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.calendar = calendar
    dateFormatter.dateFormat = DateFormatter.dateFormat(
      fromTemplate: "EEEE, MMM d, yyyy",
      options: 0,
      locale: calendar.locale ?? Locale.current)
    return dateFormatter
  }()

  private var selectedDay: Day?

  private func makeContent() -> CalendarViewContent {
    let startDate = calendar.date(from: DateComponents(year: 2020, month: 01, day: 16))!
    let endDate = calendar.date(from: DateComponents(year: 2020, month: 12, day: 05))!

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

}

