//
//  SwiftUIFlexWeekViewController.swift
//  HorizonCalendarExample
//
//  Created by Kyle Parker on 3/2/25.
//  Copyright © 2025 Airbnb. All rights reserved.
//

import Foundation

import HorizonCalendar
import SwiftUI

// MARK: - SwiftUIFlexWeekViewController

final class SwiftUIFlexWeekViewController: UIViewController, DemoViewController {
    // MARK: Lifecycle

    init(monthsLayout _: MonthsLayout) {
        monthsLayout = MonthsLayout.vertical(options: .init(pinDaysOfWeekToTop: true,
                                                            alwaysShowCompleteBoundaryMonths: true,
                                                            scrollsToFirstMonthOnStatusBarTap: true))
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    let calendar = Calendar.current
    let monthsLayout: MonthsLayout

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "SwiftUI Flexible Week View"

        let hostingController = UIHostingController(
            rootView: SwiftUIFlexWeekDemo(calendar: calendar, monthsLayout: monthsLayout))
        addChild(hostingController)

        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        hostingController.didMove(toParent: self)
    }
}

// MARK: - SwiftUIFlexWeekDemo

struct SwiftUIFlexWeekDemo: View {
    // MARK: - Lifecycle

    init(calendar: Calendar, monthsLayout: MonthsLayout) {
        self.calendar = calendar
        self.monthsLayout = monthsLayout

        let startDate = calendar.date(from: DateComponents(year: 2025, month: 01, day: 01))!
        let endDate = calendar.date(from: DateComponents(year: 2035, month: 12, day: 31))!
        visibleDateRange = startDate ... endDate

        monthDateFormatter = DateFormatter()
        monthDateFormatter.calendar = calendar
        monthDateFormatter.locale = calendar.locale
        monthDateFormatter.dateFormat = DateFormatter.dateFormat(
            fromTemplate: "MMMM yyyy",
            options: 0,
            locale: calendar.locale ?? Locale.current
        )
    }

    // MARK: Internal

    @State private var showErrorMessage: Bool = false

    var body: some View {
        ZStack {
            CalendarViewRepresentable(
                calendar: calendar,
                visibleDateRange: visibleDateRange,
                monthsLayout: monthsLayout,
                dataDependency: selectedDayRange,
                proxy: calendarViewProxy
            )

            .interMonthSpacing(28)
            .verticalDayMargin(28)
            .horizontalDayMargin(10)
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
                SwiftUIDayView(day: day, isSelected: isDaySelected(day))
            }

            .dayRangeItemProvider(for: selectedDateRanges) { dayRangeLayoutContext in
                let framesOfDaysToHighlight = dayRangeLayoutContext.daysAndFrames.map(\.frame)
                // UIKit view
                return DayRangeIndicatorView.calendarItemModel(
                    invariantViewProperties: .init(),
                    content: .init(framesOfDaysToHighlight: framesOfDaysToHighlight)
                )
            }

            .onDaySelection { day in
                DayRangeSelectionHelper.updateDayRange(
                    afterTapSelectionOf: day,
                    existingDayRange: &selectedDayRange
                )
            }
            .onAppear {
                calendarViewProxy.scrollToDay(
                    containing: calendar.date(from: DateComponents(year: 2025, month: 04, day: 01))!,
                    scrollPosition: .centered,
                    animated: false
                )
            }
            .frame(maxWidth: 375, maxHeight: .infinity)
        }
    }

    // MARK: Private

    private let calendar: Calendar
    private let monthsLayout: MonthsLayout
    private let visibleDateRange: ClosedRange<Date>

    private var dateToolTip: Date?

    private let monthDateFormatter: DateFormatter

    @State private var dayDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.current
        dateFormatter.locale = Calendar.current.locale
        dateFormatter.dateFormat = DateFormatter.dateFormat(
            fromTemplate: "EEEE, MMM d, yyyy",
            options: 0,
            locale: Locale.current
        )
        return dateFormatter
    }()

    @StateObject private var calendarViewProxy = CalendarViewProxy()

    @State private var selectedDayRange: DayComponentsRange?
    @State private var selectedDayRangeAtStartOfDrag: DayComponentsRange?

    private var selectedDateRanges: Set<ClosedRange<Date>> {
        guard let selectedDayRange else { return [] }
        let selectedStartDate = calendar.date(from: selectedDayRange.lowerBound.components)!
        let selectedEndDate = calendar.date(from: selectedDayRange.upperBound.components)!
        return [selectedStartDate ... selectedEndDate]
    }

    private func isDaySelected(_ day: Day) -> Bool {
        if let selectedDayRange {
            day == selectedDayRange.lowerBound || day == selectedDayRange.upperBound
        } else {
            false
        }
    }
}
