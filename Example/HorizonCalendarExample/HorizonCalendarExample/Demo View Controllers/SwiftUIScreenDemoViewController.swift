// Created by Bryan Keller on 2/1/23.
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
import SwiftUI

// MARK: - SwiftUIScreenDemoViewController

final class SwiftUIScreenDemoViewController: UIViewController, DemoViewController {

  // MARK: Lifecycle

  init(monthsLayout: MonthsLayout) {
    self.monthsLayout = monthsLayout
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  let calendar = Calendar.current
  let monthsLayout: MonthsLayout

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "SwiftUI Screen"

    let hostingController = UIHostingController(
      rootView: SwiftUIScreenDemo(calendar: calendar, monthsLayout: monthsLayout))
    addChild(hostingController)

    view.addSubview(hostingController.view)
    hostingController.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])

    hostingController.didMove(toParent: self)
  }

}

// MARK: - SwiftUIScreenDemo

struct SwiftUIScreenDemo: View {

  // MARK: Lifecycle

  init(calendar: Calendar, monthsLayout: MonthsLayout) {
    self.calendar = calendar
    self.monthsLayout = monthsLayout

    let startDate = calendar.date(from: DateComponents(year: 2023, month: 01, day: 01))!
    let endDate = calendar.date(from: DateComponents(year: 2026, month: 12, day: 31))!
    visibleDateRange = startDate...endDate

    monthDateFormatter = DateFormatter()
    monthDateFormatter.calendar = calendar
    monthDateFormatter.locale = calendar.locale
    monthDateFormatter.dateFormat = DateFormatter.dateFormat(
      fromTemplate: "MMMM yyyy",
      options: 0,
      locale: calendar.locale ?? Locale.current)
  }

  // MARK: Internal

  var body: some View {
    CalendarViewRepresentable(
      calendar: calendar,
      visibleDateRange: visibleDateRange,
      monthsLayout: monthsLayout,
      dataDependency: selectedDayRange,
      proxy: calendarViewProxy)

      .interMonthSpacing(24)
      .verticalDayMargin(8)
      .horizontalDayMargin(8)

      .monthHeaders { month in
        let monthHeaderText = monthDateFormatter.string(from: calendar.date(from: month.components)!)
        Group {
          if case .vertical = monthsLayout {
            HStack {
              Text(monthHeaderText)
                .font(.title2)
              Spacer()
            }
            .padding()
          } else {
            Text(monthHeaderText)
              .font(.title2)
              .padding()
          }
        }
        .accessibilityAddTraits(.isHeader)
      }

      .days { day in
        SwiftUIDayView(dayNumber: day.day, isSelected: isDaySelected(day))
      }

      .dayRangeItemProvider(for: selectedDateRanges) { dayRangeLayoutContext in
        let framesOfDaysToHighlight = dayRangeLayoutContext.daysAndFrames.map { $0.frame }
        // UIKit view
        return DayRangeIndicatorView.calendarItemModel(
          invariantViewProperties: .init(),
          content: .init(framesOfDaysToHighlight: framesOfDaysToHighlight))
      }

      .onDaySelection { day in
        DayRangeSelectionHelper.updateDayRange(
          afterTapSelectionOf: day,
          existingDayRange: &selectedDayRange)
      }

      .onMultipleDaySelectionDrag(
        began: { day in
          DayRangeSelectionHelper.updateDayRange(
            afterDragSelectionOf: day,
            existingDayRange: &selectedDayRange,
            initialDayRange: &selectedDayRangeAtStartOfDrag,
            state: .began,
            calendar: calendar)
        },
        changed: { day in
          DayRangeSelectionHelper.updateDayRange(
            afterDragSelectionOf: day,
            existingDayRange: &selectedDayRange,
            initialDayRange: &selectedDayRangeAtStartOfDrag,
            state: .changed,
            calendar: calendar)
        },
        ended: { day in
          DayRangeSelectionHelper.updateDayRange(
            afterDragSelectionOf: day,
            existingDayRange: &selectedDayRange,
            initialDayRange: &selectedDayRangeAtStartOfDrag,
            state: .ended,
            calendar: calendar)
        })

      .onAppear {
        calendarViewProxy.scrollToDay(
          containing: calendar.date(from: DateComponents(year: 2023, month: 07, day: 19))!,
          scrollPosition: .centered,
          animated: false)
      }

      .frame(maxWidth: 375, maxHeight: .infinity)
  }

  // MARK: Private

  private let calendar: Calendar
  private let monthsLayout: MonthsLayout
  private let visibleDateRange: ClosedRange<Date>

  private let monthDateFormatter: DateFormatter

  @StateObject private var calendarViewProxy = CalendarViewProxy()

  @State private var selectedDayRange: DayComponentsRange?
  @State private var selectedDayRangeAtStartOfDrag: DayComponentsRange?

  private var selectedDateRanges: Set<ClosedRange<Date>> {
    guard let selectedDayRange else { return [] }
    let selectedStartDate = calendar.date(from: selectedDayRange.lowerBound.components)!
    let selectedEndDate = calendar.date(from: selectedDayRange.upperBound.components)!
    return [selectedStartDate...selectedEndDate]
  }

  private func isDaySelected(_ day: DayComponents) -> Bool {
    if let selectedDayRange {
      return day == selectedDayRange.lowerBound || day == selectedDayRange.upperBound
    } else {
      return false
    }
  }

}

// MARK: - SwiftUIScreenDemo_Previews

struct SwiftUIScreenDemo_Previews: PreviewProvider {
  static var previews: some View {
    SwiftUIScreenDemo(calendar: Calendar.current, monthsLayout: .vertical)
    SwiftUIScreenDemo(calendar: Calendar.current, monthsLayout: .horizontal)
  }
}
