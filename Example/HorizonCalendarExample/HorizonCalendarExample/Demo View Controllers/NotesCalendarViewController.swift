// NotesCalendarViewController.swift
// A calendar that allows users to add and view notes on specific dates.

import HorizonCalendar
import UIKit

final class NotesCalendarViewController: BaseDemoViewController {

    // MARK: Lifecycle

    required init(monthsLayout: MonthsLayout) {
        super.init(monthsLayout: monthsLayout)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    var notes: [Date: String] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Notes Calendar"

        calendarView.daySelectionHandler = { [weak self] day in
            guard let self = self, let date = self.calendar.date(from: day.components) else { return }
            self.promptForNote(on: date)
        }
    }

    override func makeContent() -> CalendarViewContent {
        let startDate = calendar.date(from: DateComponents(year: 2020, month: 01, day: 01))!
        let endDate = calendar.date(from: DateComponents(year: 2023, month: 12, day: 31))!

        return CalendarViewContent(
            calendar: calendar,
            visibleDateRange: startDate...endDate,
            monthsLayout: monthsLayout)
            .interMonthSpacing(24)
            .dayItemProvider { [weak self, calendar] day in
                guard let self = self else { return nil }
                let date = calendar.date(from: day.components)
                var invariantViewProperties = DayView.InvariantViewProperties.baseInteractive

                if let note = self.notes[date ?? Date()] {
                    invariantViewProperties.backgroundShapeDrawingConfig.borderColor = .blue
                    invariantViewProperties.backgroundShapeDrawingConfig.fillColor = .blue.withAlphaComponent(0.15)
                    
                    return DayView.calendarItemModel(
                        invariantViewProperties: invariantViewProperties,
                        content: .init(
                            dayText: "\(day.day)\nNote!",
                            accessibilityLabel: date.map { DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .none) },
                            accessibilityHint: "Tap to edit note"))
                } else {
                    return DayView.calendarItemModel(
                        invariantViewProperties: invariantViewProperties,
                        content: .init(
                            dayText: "\(day.day)",
                            accessibilityLabel: date.map { DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .none) },
                            accessibilityHint: "Tap to add note"))
                }
            }
    }

    private func promptForNote(on date: Date) {
        let alert = UIAlertController(title: "Add/Edit Note", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Enter your note"
            textField.text = self.notes[date]
        }
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self, weak alert] _ in
            guard let self = self, let textField = alert?.textFields?.first, let text = textField.text, !text.isEmpty else { return }
            self.notes[date] = text
            self.calendarView.setContent(self.makeContent())
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true)
    }
}
