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
  private let dateRange = Date().addingTimeInterval(-60 * 60 * 24 * 30 * 6)...Date().addingTimeInterval(60 * 60 * 24 * 30 * 6)
  
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
      
    // Get visible items when positioned at January
    let details = visibleItemsProvider.detailsForVisibleItems(
      surroundingPreviouslyVisibleLayoutItem: LayoutItem(
        itemType: .monthHeader(Month(era: 1, year: 2024, month: 01, isInGregorianCalendar: true)),
        frame: CGRect(x: 0, y: 0, width: 320, height: 50)),
      offset: CGPoint(x: 0, y: 0),
      extendLayoutRegion: false)
      
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
      
    // Get visible items when positioned at January
    let details = visibleItemsProvider.detailsForVisibleItems(
      surroundingPreviouslyVisibleLayoutItem: LayoutItem(
        itemType: .monthHeader(Month(era: 1, year: 2024, month: 01, isInGregorianCalendar: true)),
        frame: CGRect(x: 0, y: 0, width: 320, height: 50)),
      offset: CGPoint(x: 0, y: 0),
      extendLayoutRegion: false)
      
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
      
    // Get visible items when positioned at January 2024
    let details = visibleItemsProvider.detailsForVisibleItems(
      surroundingPreviouslyVisibleLayoutItem: LayoutItem(
        itemType: .monthHeader(Month(era: 1, year: 2024, month: 01, isInGregorianCalendar: true)),
        frame: CGRect(x: 0, y: 0, width: 320, height: 50)),
      offset: CGPoint(x: 0, y: 0),
      extendLayoutRegion: false)
      
    // Find items with weekNumber type
    let weekNumberItems = details.visibleItems.compactMap { item -> (Int, Month)? in
      if case .weekNumber(let weekNumber, let month) = item.itemType {
        return (weekNumber, month)
      }
      return nil
    }
    
    // Verify that we have some week numbers
    XCTAssertFalse(weekNumberItems.isEmpty, "Week numbers should be visible")
    
    // Verify that week numbers are in ascending order
    var lastWeekNumber = 0
    for (weekNumber, _) in weekNumberItems {
      if lastWeekNumber > 0 {
        // Allow jumping back to week 1 for new years
        if !(lastWeekNumber > 50 && weekNumber < 10) {
          XCTAssertGreaterThanOrEqual(weekNumber, lastWeekNumber, "Week numbers should be ascending")
        }
      }
      lastWeekNumber = weekNumber
    }
    
    // Verify first week number is valid (should be 1 or close to it for January)
    if let firstWeekNumber = weekNumberItems.first?.0 {
      XCTAssertTrue(firstWeekNumber < 5, "First week of January should be low week number")
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
      
    // Get visible items when positioned at January
    let details = visibleItemsProvider.detailsForVisibleItems(
      surroundingPreviouslyVisibleLayoutItem: LayoutItem(
        itemType: .monthHeader(Month(era: 1, year: 2024, month: 01, isInGregorianCalendar: true)),
        frame: CGRect(x: 0, y: 0, width: 320, height: 50)),
      offset: CGPoint(x: 0, y: 0),
      extendLayoutRegion: false)
      
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
    
    // Verify that week numbers are positioned to the left of days
    XCTAssertFalse(dayItems.isEmpty, "Day items should be present")
    XCTAssertFalse(weekNumberItems.isEmpty, "Week number items should be present")
    
    // Find the rightmost x position of week numbers
    if let maxWeekNumberX = weekNumberItems.map({ $0.frame.maxX }).max(),
       let minDayX = dayItems.map({ $0.frame.minX }).min()
    {
      XCTAssertLessThanOrEqual(maxWeekNumberX, minDayX, "Week numbers should be positioned to the left of days")
    }
  }
}
