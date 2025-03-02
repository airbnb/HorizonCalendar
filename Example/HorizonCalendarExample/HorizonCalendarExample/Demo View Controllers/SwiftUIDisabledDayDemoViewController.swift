//
//  SwiftUIDisabledDayDemoViewController.swift
//  HorizonCalendarExample
//
//  Created by Kyle Parker on 3/1/25.
//  Copyright © 2025 Airbnb. All rights reserved.
//

import HorizonCalendar
import SwiftUI

// MARK: - SwiftUIDisabledDayDemoViewController

final class SwiftUIDisabledDayDemoViewController: UIViewController, DemoViewController {
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

      title = "SwiftUI Disabled Day"

      let hostingController = UIHostingController(
        rootView: SwiftUIDisabledDayDemo(calendar: calendar, monthsLayout: monthsLayout))
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

// MARK: - SwiftUIDisabledDayDemo

struct SwiftUIDisabledDayDemo: View, DayAvailabilityProvider {
    func isEnabled(_ day: HorizonCalendar.DayComponents) -> Bool {
        let dateComponents = day.components
        guard let date = calendar.date(from: dateComponents) else {
            return true
        }
        
        let calendar = Calendar.current
        let yr = dateComponents.year ?? 0
        let mth = dateComponents.month ?? 0
        let day = dateComponents.day ?? 0
        
        // Disable the 18th
        if (day == 18) {
            return false
        }
        
        /// Disable each Friday in Jan.
        if mth == 1 && calendar.component(.weekday, from: date) == 6 {
            return false
        }
        
        // Disable the first week in Feb. every 4 years
        if mth == 2 && (yr % 4 == 0) && day <= 7 {
            return false
        }
        
        // Disable the second week in March (per day, not cal week)
        if mth == 3 && (8...14).contains(day) {
            return false
        }
        
        // Disable May 5th - 10th
        if mth == 5 && (5...10).contains(day) {
            return false
        }
        
        // Disable Multiples of 9 in sep
        if mth == 9 && day.isMultiple(of: 9) {
            return false
        }
        
        // Disable halloween
        if mth == 10 && day == 31 {
            return false
        }
        
        // Disable week around thanksgiving
        if mth == 11 && (day >= 22 && day <= 30) {
            return false
        }
        
        let federalHolidays: [Date] = [
            Calendar.current.date(from: DateComponents(year: yr, month: 1, day: 1))!,
            Calendar.current.date(from: DateComponents(year: yr, month: 7, day: 4))!,
            Calendar.current.date(from: DateComponents(year: yr, month: 12, day: 25))!
        ]
        
        if federalHolidays.contains(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
            return false
        }
        
        return true
    }
    
    func isEnabled(_ date: Date) -> Bool {
        return isEnabled(DayComponents(date: date))
    }
    
    
    // MARK: Lifecycle

    init(calendar: Calendar, monthsLayout: MonthsLayout) {
      self.calendar = calendar
      self.monthsLayout = monthsLayout

      let startDate = calendar.date(from: DateComponents(year: 2025, month: 01, day: 01))!
      let endDate = calendar.date(from: DateComponents(year: 2035, month: 12, day: 31))!
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
    
    @State private var showErrorMessage: Bool = false

    var body: some View {
        ZStack {
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
                SwiftUIDayView(day: day, isSelected: isDaySelected(day))
            }

            .dayRangeItemProvider(for: selectedDateRanges) { dayRangeLayoutContext in
              let framesOfDaysToHighlight = dayRangeLayoutContext.daysAndFrames.map { $0.frame }
              // UIKit view
              return DayRangeIndicatorView.calendarItemModel(
                invariantViewProperties: .init(),
                content: .init(framesOfDaysToHighlight: framesOfDaysToHighlight))
            }

            .onDaySelection { day in
                invalidDates = DayRangeSelectionHelper.updateDayRange(
                afterTapSelectionOf: day,
                existingDayRange: &selectedDayRange)
                
                showErrorMessage = invalidDates != []
            }

            .onMultipleDaySelectionDrag(
              began: { day in
                  invalidDates = DayRangeSelectionHelper.updateDayRange(
                  afterDragSelectionOf: day,
                  existingDayRange: &selectedDayRange,
                  initialDayRange: &selectedDayRangeAtStartOfDrag,
                  state: .began,
                  calendar: calendar)
                  
                  showErrorMessage = invalidDates != []
              },
              changed: { day in
                  invalidDates =  DayRangeSelectionHelper.updateDayRange(
                  afterDragSelectionOf: day,
                  existingDayRange: &selectedDayRange,
                  initialDayRange: &selectedDayRangeAtStartOfDrag,
                  state: .changed,
                  calendar: calendar)
                  
                  showErrorMessage = invalidDates != []
              },
              ended: { day in
                  invalidDates = DayRangeSelectionHelper.updateDayRange(
                  afterDragSelectionOf: day,
                  existingDayRange: &selectedDayRange,
                  initialDayRange: &selectedDayRangeAtStartOfDrag,
                  state: .ended,
                  calendar: calendar)
                  
                  showErrorMessage = invalidDates != []
              })

            .onAppear {
                Day.availabilityProvider = self
              calendarViewProxy.scrollToDay(
                containing: calendar.date(from: DateComponents(year: 2025, month: 04, day: 01))!,
                scrollPosition: .centered,
                animated: false)
            }
            
            .onDisappear {
                Day.availabilityProvider = nil
            }

            .frame(maxWidth: 375, maxHeight: .infinity)
            
            if showErrorMessage {
                overlayView
                    .transition(.opacity)
                    .animation(.easeInOut, value: showErrorMessage)
            }
        }
    }

    // MARK: Private
    
    // MARK: Views
    private var overlayView: some View {
        VStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    Text("Unfornately, these dates are unavailable:\n\(getInvalidDatesString())")
                        .foregroundColor(.white)
                        .font(.system(size: 25))
                        .padding()
                )
            Spacer()
        }
        .onTapGesture {
            self.showErrorMessage = false
            self.invalidDates = []
        }
    }

    private let calendar: Calendar
    private let monthsLayout: MonthsLayout
    private let visibleDateRange: ClosedRange<Date>
    
    private var dateToolTip: Date?

    private let monthDateFormatter: DateFormatter
    
    @State private var invalidDates: Set<Date> = []
    
    @State private var dayDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.current
        dateFormatter.locale = Calendar.current.locale
        dateFormatter.dateFormat = DateFormatter.dateFormat(
            fromTemplate: "EEEE, MMM d, yyyy",
            options: 0,
            locale: Locale.current)
        return dateFormatter
    }()

    @StateObject private var calendarViewProxy = CalendarViewProxy()

    @State private var selectedDayRange: DayComponentsRange?
    @State private var selectedDayRangeAtStartOfDrag: DayComponentsRange?

    private var selectedDateRanges: Set<ClosedRange<Date>> {
        guard let selectedDayRange else { return [] }
        let selectedStartDate = calendar.date(from: selectedDayRange.lowerBound.components)!
        let selectedEndDate = calendar.date(from: selectedDayRange.upperBound.components)!
        return [selectedStartDate...selectedEndDate]
    }

    private func isDaySelected(_ day: Day) -> Bool {
        if let selectedDayRange {
            return (day == selectedDayRange.lowerBound || day == selectedDayRange.upperBound)
        } else {
            return false
        }
    }
    
    private func getInvalidDatesString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy"

        let formattedDates = invalidDates.sorted().enumerated().map { index, date in
            return "\(index + 1)) \(dateFormatter.string(from: date))"
        }

        return formattedDates.joined(separator: "\n")
    }
}
