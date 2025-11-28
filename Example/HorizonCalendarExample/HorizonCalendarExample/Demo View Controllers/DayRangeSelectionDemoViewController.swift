import UIKit
import HorizonCalendar

final class DayRangeSelectionDemoViewController: BaseDemoViewController {

    // Properties for storing multiple date ranges and their respective colors
    private var dateRanges: [ClosedRange<Date>] = []
    private var dateRangeColors: [ClosedRange<Date>: UIColor] = [:]
    private var currentRangeStart: Date?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Day Range Selection"

        calendarView.daySelectionHandler = { [weak self] day in
            guard let self = self, let date = self.calendar.date(from: day.components) else { return }

            if let start = self.currentRangeStart {
                // Complete the current range and prompt for a color
                let newRange = start...date
                self.dateRanges.append(newRange)
                self.currentRangeStart = nil  // Reset the start date for a new range

                self.promptForColorSelection(dateRange: newRange) { color in
                    self.dateRangeColors[newRange] = color
                    self.calendarView.setContent(self.makeContent())
                }
            } else {
                // Start a new range
                self.currentRangeStart = date
            }
        }
    }

    private func promptForColorSelection(dateRange: ClosedRange<Date>, completion: @escaping (UIColor) -> Void) {
        let alert = UIAlertController(title: "Select Color", message: "Choose a color for the selected date range", preferredStyle: .actionSheet)
        
        let colors: [UIColor: String] = [.red: "Red", .green: "Green", .blue: "Blue", .orange: "Orange"]
        for (color, name) in colors {
            alert.addAction(UIAlertAction(title: name, style: .default, handler: { _ in
                completion(color)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    override func makeContent() -> CalendarViewContent {
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2020, month: 01, day: 01))!
        let endDate = calendar.date(from: DateComponents(year: 2021, month: 12, day: 31))!

        // Map your date ranges to ClosedRange<Date> using correct component extraction
        let dateRanges = self.dateRanges.map { range -> ClosedRange<Date> in
            let startComponents = calendar.dateComponents([.year, .month, .day], from: range.lowerBound)
            let endComponents = calendar.dateComponents([.year, .month, .day], from: range.upperBound)
            let start = calendar.date(from: startComponents)!
            let end = calendar.date(from: endComponents)!
            return start...end
        }

        return CalendarViewContent(
            calendar: calendar,
            visibleDateRange: startDate...endDate,
            monthsLayout: monthsLayout)
            .interMonthSpacing(24)
            .verticalDayMargin(8)
            .horizontalDayMargin(8)
            .dayItemProvider { [weak self, dateRangeColors] day in
                guard let self = self else { return nil }
                var invariantViewProperties = DayView.InvariantViewProperties.baseInteractive
                let date = calendar.date(from: day.components)!

                // Apply colors to date ranges
                for (range, color) in dateRangeColors {
                    if range.contains(date) {
                        invariantViewProperties.backgroundShapeDrawingConfig.borderColor = color
                        invariantViewProperties.backgroundShapeDrawingConfig.fillColor = color.withAlphaComponent(0.15)
                        break
                    }
                }

                return DayView.calendarItemModel(
                    invariantViewProperties: invariantViewProperties,
                    content: .init(
                        dayText: "\(day.day)",
                        accessibilityLabel: self.dayDateFormatter.string(from: date),
                        accessibilityHint: nil))
            }
    }

}
