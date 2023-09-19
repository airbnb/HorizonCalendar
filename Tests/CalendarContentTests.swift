// Created by Cal Stephens on 9/18/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

@testable import HorizonCalendar
import XCTest

final class CalendarContentTests: XCTestCase {

  func testCanReturnNilFromCalendarContentClosures() {
    _ = CalendarViewContent(
      visibleDateRange: Date.distantPast...Date.distantFuture, 
      monthsLayout: .vertical)
    .monthHeaderItemProvider { _ in
      nil
    }
    .dayOfWeekItemProvider { _, _ in
      nil
    }
    .dayItemProvider { _ in
      nil
    }
    .dayBackgroundItemProvider { _ in
      nil
    }
  }

  func testNilDayItemUsesDefaultValue() {
    let content = CalendarViewContent(
      visibleDateRange: Date.distantPast...Date.distantFuture,
      monthsLayout: .vertical)

    let day = Day(month: Month(era: 1, year: 2023, month: 1, isInGregorianCalendar: true), day: 1)
    let defaultDayItem = content.dayItemProvider(day)

    let contentWithNilDayItem = content.dayItemProvider { _ in nil }
    let updatedDayItem = contentWithNilDayItem.dayItemProvider(day)

    XCTAssert(defaultDayItem._isContentEqual(toContentOf: updatedDayItem))
  }

  func testNilDayOfWeekItemUsesDefaultValue() {
    let content = CalendarViewContent(
      visibleDateRange: Date.distantPast...Date.distantFuture,
      monthsLayout: .vertical)

    let month = Month(era: 1, year: 2023, month: 1, isInGregorianCalendar: true)
    let defaultDayOfWeekItem = content.dayOfWeekItemProvider(month, 1)

    let contentWithNilDayOfWeekItem = content.dayOfWeekItemProvider { _, _ in nil }
    let updatedDayOfWeekItem = contentWithNilDayOfWeekItem.dayOfWeekItemProvider(month, 1)

    XCTAssert(defaultDayOfWeekItem._isContentEqual(toContentOf: updatedDayOfWeekItem))
  }

  func testNilMonthHeaderItemUsesDefaultValue() {
    let content = CalendarViewContent(
      visibleDateRange: Date.distantPast...Date.distantFuture,
      monthsLayout: .vertical)

    let month = Month(era: 1, year: 2023, month: 1, isInGregorianCalendar: true)
    let defaultMonthHeaderItem = content.monthHeaderItemProvider(month)

    let contentWithNilMonthHeaderItem = content.monthHeaderItemProvider { _ in nil }
    let updatedMonthHeaderItem = contentWithNilMonthHeaderItem.monthHeaderItemProvider(month)

    XCTAssert(defaultMonthHeaderItem._isContentEqual(toContentOf: updatedMonthHeaderItem))
  }

}
