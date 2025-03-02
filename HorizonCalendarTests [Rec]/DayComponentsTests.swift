//
//  DayComponentTests.swift
//  HorizonCalendarTests
//
//  Created by Kyle Parker on 3/1/25.
//  Copyright © 2025 Airbnb. All rights reserved.
//

import Testing
import HorizonCalendar
import Foundation

struct DayComponentTests {

    @available(iOS 13.0.0, *)
    @Test func testGreaterThanOperatorSameMonthTrue() async throws {
        let early = DayComponents(date: createDate(year: 2025, month: 01, day: 01))
        let late = DayComponents(date: createDate(year: 2025, month: 01, day: 02))

        #expect(early < late)
    }

    @available(iOS 13.0.0, *)
    @Test func testGreaterThanOperatorSameMonthFalse() async throws {
        let early = DayComponents(date: createDate(year: 2025, month: 01, day: 01))
        let late = DayComponents(date: createDate(year: 2025, month: 01, day: 02))

        #expect((late < early) == false)
    }
    
    @available(iOS 13.0.0, *)
    @Test func testGreaterThanOperatorSameMonthEqualFalse() async throws {
        let early = DayComponents(date: createDate(year: 2025, month: 01, day: 01))
        let late = DayComponents(date: createDate(year: 2025, month: 01, day: 01))

        #expect((late < early) == false)
    }

    @available(iOS 13.0.0, *)
    @Test func testGreaterThanOperatorDifferentMonthsTrue() async throws {
        let early = DayComponents(date: createDate(year: 2024, month: 12, day: 31))
        let late = DayComponents(date: createDate(year: 2025, month: 01, day: 01))

        #expect(early < late)
    }

    @available(iOS 13.0.0, *)
    @Test func testGreaterThanOperatorDifferentMonthsFalse() async throws {
        let early = DayComponents(date: createDate(year: 2024, month: 12, day: 31))
        let late = DayComponents(date: createDate(year: 2025, month: 01, day: 01))

        #expect((late < early) == false)
    }
    
    private func createDate(year: Int, month: Int, day: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        return Calendar.current.date(from: dateComponents)!
    }
}
