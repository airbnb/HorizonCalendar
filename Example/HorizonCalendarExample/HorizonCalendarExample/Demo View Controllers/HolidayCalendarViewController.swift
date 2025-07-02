// Created by Bryan Keller on 8/23/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

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
import UIKit

final class HolidayCalendarViewController: BaseDemoViewController {

    // MARK: Lifecycle

    required init(monthsLayout: MonthsLayout) {
        super.init(monthsLayout: monthsLayout)
        selectedDate = calendar.date(from: DateComponents(year: 2020, month: 01, day: 19))!
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Holiday Calendar"

        calendarView.daySelectionHandler = { [weak self] day in
            guard let self = self else { return }

            self.selectedDate = self.calendar.date(from: day.components)
            self.calendarView.setContent(self.makeContent())
        }
    }

    override func makeContent() -> CalendarViewContent {
        let startDate = calendar.date(from: DateComponents(year: 2023, month: 01, day: 01))!
        let endDate = calendar.date(from: DateComponents(year: 2023, month: 12, day: 31))!

        let holidays = loadHolidays()

        return CalendarViewContent(
            calendar: calendar,
            visibleDateRange: startDate...endDate,
            monthsLayout: monthsLayout)
            .interMonthSpacing(24)
            .verticalDayMargin(8)
            .horizontalDayMargin(8)
            .dayItemProvider { [calendar] day in
                let date = calendar.date(from: day.components)
                var invariantViewProperties = DayView.InvariantViewProperties.baseInteractive

                if let holidayName = holidays[date ?? Date()] {
                    invariantViewProperties.backgroundShapeDrawingConfig.borderColor = .red
                    invariantViewProperties.backgroundShapeDrawingConfig.fillColor = .red.withAlphaComponent(0.15)
                    
                    return DayView.calendarItemModel(
                        invariantViewProperties: invariantViewProperties,
                        content: .init(
                            dayText: "\(day.day)\n\(holidayName)",
                            accessibilityLabel: date.map { DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .none) },
                            accessibilityHint: nil))
                } else {
                    return DayView.calendarItemModel(
                        invariantViewProperties: invariantViewProperties,
                        content: .init(
                            dayText: "\(day.day)",
                            accessibilityLabel: date.map { DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .none) },
                            accessibilityHint: nil))
                }
            }
    }

    // MARK: Private

    private var selectedDate: Date?

    private func loadHolidays() -> [Date: String] {
        // Example static holidays; replace with your data source logic
        var holidays: [Date: String] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        // Common International Holidays
            holidays[formatter.date(from: "2023/01/01")!] = "New Year's Day"
            holidays[formatter.date(from: "2023/02/14")!] = "Valentine's Day"
            holidays[formatter.date(from: "2023/03/17")!] = "St. Patrick's Day"
            holidays[formatter.date(from: "2023/04/01")!] = "April Fool's Day"
            holidays[formatter.date(from: "2023/10/31")!] = "Halloween"
            holidays[formatter.date(from: "2023/12/25")!] = "Christmas Day"
            holidays[formatter.date(from: "2023/12/31")!] = "New Year's Eve"
            
            // USA Specific Holidays
            holidays[formatter.date(from: "2023/07/04")!] = "Independence Day"
            holidays[formatter.date(from: "2023/11/24")!] = "Thanksgiving Day"
            
            // Other Significant Dates
            holidays[formatter.date(from: "2023/05/05")!] = "Cinco de Mayo"
            holidays[formatter.date(from: "2023/07/14")!] = "Bastille Day"
            holidays[formatter.date(from: "2023/10/03")!] = "German Unity Day"
            
            // Religious Holidays
            holidays[formatter.date(from: "2023/04/09")!] = "Easter Sunday"
            holidays[formatter.date(from: "2023/12/12")!] = "Hanukkah Starts"   
            holidays[formatter.date(from: "2023/07/28")!] = "Eid al-Adha"
            holidays[formatter.date(from: "2023/11/12")!] = "Diwali"
            
            // Additional Holidays
            holidays[formatter.date(from: "2023/03/08")!] = "International Women's Day"
            holidays[formatter.date(from: "2023/05/01")!] = "International Workers' Day"
            holidays[formatter.date(from: "2023/06/19")!] = "Juneteenth"
            holidays[formatter.date(from: "2023/08/09")!] = "International Day of the World's Indigenous Peoples"
            holidays[formatter.date(from: "2023/09/21")!] = "International Day of Peace"
            holidays[formatter.date(from: "2023/11/20")!] = "Universal Children's Day"
        return holidays
    }

}
