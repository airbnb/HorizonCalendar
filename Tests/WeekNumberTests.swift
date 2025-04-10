//
//  WeekNumberTests.swift
//  HorizonCalendar
//
//  Created by Cade Chaplin on 3/1/25.
//  Copyright © 2025 Airbnb. All rights reserved.
//

import XCTest
@testable import HorizonCalendar

final class WeekNumberTests: XCTestCase {
  
  // MARK: - Common Test Properties
  
  private let calendar = Calendar(identifier: .gregorian)
  private let size = CGSize(width: 320, height: 500)
  
  // Use a fixed date range for stable testing - January through March 2023
  private var dateRange: ClosedRange<Date> {
    let startComponents = DateComponents(year: 2023, month: 1, day: 1)
    let endComponents = DateComponents(year: 2023, month: 3, day: 31)
    
    let startDate = calendar.date(from: startComponents)!
    let endDate = calendar.date(from: endComponents)!
    
    return startDate...endDate
  }
  
  // A month that's guaranteed to be in our date range
  private var testMonth: Month {
    return Month(era: 1, year: 2023, month: 1, isInGregorianCalendar: true)
  }
  
  // MARK: - Tests

  func testWeekNumbersAreVisibleWhenEnabled() {
    // Create content with week numbers enabled
    let content = CalendarViewContent(
      calendar: calendar,
      visibleDateRange: dateRange,
      monthsLayout: .vertical(options: .init()))
      .showWeekNumbers(true)
      
    let visibleItemsProvider = VisibleItemsProvider(
      calendar: calendar,
      content: content,
      size: size,
      layoutMargins: .zero,
      scale: 2,
      backgroundColor: nil)
    
    let details = visibleItemsProvider.detailsForVisibleItems(
      surroundingPreviouslyVisibleLayoutItem: LayoutItem(
        itemType: .monthHeader(testMonth),
        frame: CGRect(x: 0, y: 0, width: size.width, height: 50)),
      offset: .zero,
      extendLayoutRegion: true)
      
    // Find items with weekNumber type
    let weekNumberItems = details.visibleItems.filter {
      if case .weekNumber = $0.itemType {
        return true
      }
      return false
    }
    
    // Verify that week numbers are visible
    XCTAssertFalse(weekNumberItems.isEmpty, "Week numbers should be visible when enabled")
  }
  
  func testWeekNumbersAreHiddenWhenDisabled() {
    // Create content with week numbers disabled (default)
    let content = CalendarViewContent(
      calendar: calendar,
      visibleDateRange: dateRange,
      monthsLayout: .vertical(options: .init()))
      
    let visibleItemsProvider = VisibleItemsProvider(
      calendar: calendar,
      content: content,
      size: size,
      layoutMargins: .zero,
      scale: 2,
      backgroundColor: nil)
      
    let details = visibleItemsProvider.detailsForVisibleItems(
      surroundingPreviouslyVisibleLayoutItem: LayoutItem(
        itemType: .monthHeader(testMonth),
        frame: CGRect(x: 0, y: 0, width: size.width, height: 50)),
      offset: .zero,
      extendLayoutRegion: true)
      
    // Find items with weekNumber type
    let weekNumberItems = details.visibleItems.filter {
      if case .weekNumber = $0.itemType {
        return true
      }
      return false
    }
    
    // Verify that week numbers are not visible
    XCTAssertTrue(weekNumberItems.isEmpty, "Week numbers should not be visible when disabled")
  }
  
  func testWeekNumbersHaveCorrectValue() {
    // Create content with week numbers enabled
    let content = CalendarViewContent(
      calendar: calendar,
      visibleDateRange: dateRange,
      monthsLayout: .vertical(options: .init()))
      .showWeekNumbers(true)
      
    let visibleItemsProvider = VisibleItemsProvider(
      calendar: calendar,
      content: content,
      size: size,
      layoutMargins: .zero,
      scale: 2,
      backgroundColor: nil)
      
    let details = visibleItemsProvider.detailsForVisibleItems(
      surroundingPreviouslyVisibleLayoutItem: LayoutItem(
        itemType: .monthHeader(testMonth),
        frame: CGRect(x: 0, y: 0, width: size.width, height: 50)),
      offset: .zero,
      extendLayoutRegion: true)
      
    // Find items with weekNumber type
    let weekNumberItems = details.visibleItems.compactMap { item -> (Int, Month)? in
      if case .weekNumber(let weekNumber, let month) = item.itemType {
        return (weekNumber, month)
      }
      return nil
    }
    
    // Verify that we have some week numbers
    XCTAssertFalse(weekNumberItems.isEmpty, "Week numbers should be visible")
    
    if !weekNumberItems.isEmpty {
      // Group week numbers by month
      let weekNumbersByMonth = Dictionary(grouping: weekNumberItems) { $0.1 }
      
      // Verify that within each month, week numbers are valid
      for (month, weekNumbersInMonth) in weekNumbersByMonth {
        // Sort by week number
        let sortedWeekNumbers = weekNumbersInMonth.map { $0.0 }.sorted()
        
        // Check for uniqueness - should have one week number per week in month
        let uniqueWeekNumbers = Set(sortedWeekNumbers)
        XCTAssertEqual(uniqueWeekNumbers.count, sortedWeekNumbers.count, 
                      "Week numbers within a month should be unique")
        
        // Check that all numbers are valid week numbers (1-53)
        for weekNumber in sortedWeekNumbers {
          XCTAssertGreaterThanOrEqual(weekNumber, 1, "Week numbers should be at least 1")
          XCTAssertLessThanOrEqual(weekNumber, 53, "Week numbers should be at most 53")
        }
        
        // For January 2023, check that it has a valid first week
        if month.month == 1 && month.year == 2023 {
          if let firstWeekNumber = sortedWeekNumbers.first {
            // First week of the year can be week 1 or week 52/53 from previous year
            XCTAssertTrue(
              firstWeekNumber == 1 || firstWeekNumber >= 52,
              "First week of January should be week 1 or from the end of previous year"
            )
          }
        }
      }
    }
  }
  
  func testWeekNumbersPositioning() {
    // Create content with week numbers enabled
    let content = CalendarViewContent(
      calendar: calendar,
      visibleDateRange: dateRange,
      monthsLayout: .vertical(options: .init()))
      .showWeekNumbers(true)
      
    let visibleItemsProvider = VisibleItemsProvider(
      calendar: calendar,
      content: content,
      size: size,
      layoutMargins: .zero,
      scale: 2,
      backgroundColor: nil)
      
    let details = visibleItemsProvider.detailsForVisibleItems(
      surroundingPreviouslyVisibleLayoutItem: LayoutItem(
        itemType: .monthHeader(testMonth),
        frame: CGRect(x: 0, y: 0, width: size.width, height: 50)),
      offset: .zero,
      extendLayoutRegion: true)
      
    // Get all day items
    let dayItems = details.visibleItems.filter {
      if case .layoutItemType(.day) = $0.itemType {
        return true
      }
      return false
    }
    
    // Get all week number items
    let weekNumberItems = details.visibleItems.filter {
      if case .weekNumber = $0.itemType {
        return true
      }
      return false
    }
    
    // Verify that days and week numbers are present
    XCTAssertFalse(dayItems.isEmpty, "Day items should be present")
    XCTAssertFalse(weekNumberItems.isEmpty, "Week number items should be present")
    
    if !dayItems.isEmpty && !weekNumberItems.isEmpty {
      // Find the rightmost x position of week numbers
      let maxWeekNumberX = weekNumberItems.map({ $0.frame.maxX }).max()!
      let minDayX = dayItems.map({ $0.frame.minX }).min()!
      
      XCTAssertLessThanOrEqual(maxWeekNumberX, minDayX, "Week numbers should be positioned to the left of days")
      
      // Check that week numbers are aligned at the same x position
      let weekNumberXPositions = Set(weekNumberItems.map { $0.frame.minX })
      XCTAssertEqual(weekNumberXPositions.count, 1, "All week numbers should be aligned to the same x position")
    }
  }
}
