// Created by Bryan Keller on 6/18/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import HorizonCalendar
import UIKit

class DemoViewController: UIViewController {

  // MARK: Lifecycle

  required init(monthsLayout: MonthsLayout) {
    self.monthsLayout = monthsLayout

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  let monthsLayout: MonthsLayout

  lazy var calendarView = CalendarView(initialContent: makeContent())
  lazy var calendar = Calendar.current
  lazy var dayDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.calendar = calendar
    dateFormatter.locale = calendar.locale
    dateFormatter.dateFormat = DateFormatter.dateFormat(
      fromTemplate: "EEEE, MMM d, yyyy",
      options: 0,
      locale: calendar.locale ?? Locale.current)
    return dateFormatter
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

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

  func makeContent() -> CalendarViewContent {
    fatalError("Must be implemented by a subclass.")
  }

}
