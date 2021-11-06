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
        calendarView.topAnchor.constraint(equalTo: view.topAnchor),
        calendarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        calendarView.leadingAnchor.constraint(
          greaterThanOrEqualTo: view.layoutMarginsGuide.leadingAnchor),
        calendarView.trailingAnchor.constraint(
          lessThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor),
        calendarView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        calendarView.widthAnchor.constraint(lessThanOrEqualToConstant: 375),
        calendarView.widthAnchor.constraint(equalToConstant: 375).prioritize(at: .defaultLow),
      ])
    case .horizontal:
      NSLayoutConstraint.activate([
        calendarView.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),
        calendarView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor),
        calendarView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor),
        calendarView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        calendarView.widthAnchor.constraint(lessThanOrEqualToConstant: 375),
        calendarView.widthAnchor.constraint(equalToConstant: 375).prioritize(at: .defaultLow),
      ])
    }
  }

  func makeContent() -> CalendarViewContent {
    fatalError("Must be implemented by a subclass.")
  }

}

// MARK: NSLayoutConstraint + Priority Helper

extension NSLayoutConstraint {

  fileprivate func prioritize(at priority: UILayoutPriority) -> NSLayoutConstraint {
    self.priority = priority
    return self
  }

}
