// Created by Bryan Keller on 3/31/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

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

import XCTest
@testable import HorizonCalendar

// MARK: - FrameProviderTests

final class FrameProviderTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    let size = CGSize(width: 320, height: 480)
    let monthHeaderHeight = CGFloat(50)

    let lowerBoundDate = calendar.date(from: DateComponents(year: 2020, month: 05, day: 15))!
    let upperBoundDate = calendar.date(from: DateComponents(year: 2020, month: 07, day: 20))!

    verticalFrameProvider = FrameProvider(
      content: CalendarViewContent(
        calendar: calendar,
        visibleDateRange: Date.distantPast...Date.distantFuture,
        monthsLayout: .vertical(options: VerticalMonthsLayoutOptions()))
        .withMonthDayInsets(UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8))
        .withInterMonthSpacing(20)
        .withVerticalDayMargin(20)
        .withHorizontalDayMargin(10),
      size: size,
      layoutMargins: .zero,
      scale: 3,
      monthHeaderHeight: monthHeaderHeight)
    verticalPinnedDaysOfWeekFrameProvider = FrameProvider(
      content: CalendarViewContent(
        calendar: calendar,
        visibleDateRange: Date.distantPast...Date.distantFuture,
        monthsLayout: .vertical(options: VerticalMonthsLayoutOptions(pinDaysOfWeekToTop: true)))
        .withMonthDayInsets(UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8))
        .withInterMonthSpacing(20)
        .withVerticalDayMargin(20)
        .withHorizontalDayMargin(10),
      size: size,
      layoutMargins: .zero,
      scale: 3,
      monthHeaderHeight: monthHeaderHeight)
    verticalPartialMonthFrameProvider = FrameProvider(
      content: CalendarViewContent(
        calendar: calendar,
        visibleDateRange: lowerBoundDate...upperBoundDate,
        monthsLayout: .vertical(
          options: VerticalMonthsLayoutOptions(alwaysShowCompleteBoundaryMonths: false)))
        .withMonthDayInsets(UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8))
        .withInterMonthSpacing(20)
        .withVerticalDayMargin(20)
        .withHorizontalDayMargin(10),
      size: size,
      layoutMargins: .zero,
      scale: 3,
      monthHeaderHeight: monthHeaderHeight)
    horizontalFrameProvider = FrameProvider(
      content: CalendarViewContent(
        calendar: calendar,
        visibleDateRange: Date.distantPast...Date.distantFuture,
        monthsLayout: .horizontal(monthWidth: 300))
        .withMonthDayInsets(UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8))
        .withInterMonthSpacing(20)
        .withVerticalDayMargin(20)
        .withHorizontalDayMargin(10),
      size: size,
      layoutMargins: .zero,
      scale: 3,
      monthHeaderHeight: monthHeaderHeight)
  }

  func testDaySize() {
    let size1 = verticalFrameProvider.daySize.alignedToPixels(forScreenWithScale: 3)
    let expectedSize1 = CGSize(width: 34.857142857142854, height: 34.857142857142854)
      .alignedToPixels(forScreenWithScale: 3)
    XCTAssert(size1 == expectedSize1, "Incorrect day size.")

    let size2 = verticalPinnedDaysOfWeekFrameProvider.daySize.alignedToPixels(forScreenWithScale: 3)
    let expectedSize2 = CGSize(width: 34.857142857142854, height: 34.857142857142854)
      .alignedToPixels(forScreenWithScale: 3)
    XCTAssert(size2 == expectedSize2, "Incorrect day size.")

    let size3 = horizontalFrameProvider.daySize.alignedToPixels(forScreenWithScale: 3)
    let expectedSize3 = CGSize(width: 32, height: 32).alignedToPixels(forScreenWithScale: 3)
    XCTAssert(size3 == expectedSize3, "Incorrect day size.")
  }

  // MARK: Test initial month calculations

  func testInitialMonthHeaderFrame() {
    let frame1 = verticalFrameProvider.frameOfMonthHeader(inMonthWithOrigin: CGPoint(x: 0, y: 100))
      .alignedToPixels(forScreenWithScale: 3)
    let expectedFrame1 = CGRect(x: 0, y: 100, width: 320, height: 50)
      .alignedToPixels(forScreenWithScale: 3)
    XCTAssert(frame1 == expectedFrame1, "Incorrect initial month header frame.")

    let frame2 = verticalPinnedDaysOfWeekFrameProvider.frameOfMonthHeader(
      inMonthWithOrigin: CGPoint(x: 0, y: 100))
      .alignedToPixels(forScreenWithScale: 3)
    let expectedFrame2 = CGRect(x: 0, y: 100, width: 320, height: 50)
      .alignedToPixels(forScreenWithScale: 3)
    XCTAssert(frame2 == expectedFrame2, "Incorrect initial month header frame.")

    let frame3 = horizontalFrameProvider.frameOfMonthHeader(
      inMonthWithOrigin: CGPoint(x: 100, y: 0))
      .alignedToPixels(forScreenWithScale: 3)
    let expectedFrame3 = CGRect(x: 100, y: 0, width: 300, height: 50)
    XCTAssert(frame3 == expectedFrame3, "Incorrect initial month header frame.")
  }

  func testMonthOriginContainingItem() {
    let expectedOrigins1 = [
      CGPoint(x: 0, y: 100).alignedToPixels(forScreenWithScale: 3),
      CGPoint(x: 0, y: 100).alignedToPixels(forScreenWithScale: 3),
      CGPoint(x: 0, y: 100).alignedToPixels(forScreenWithScale: 3),
      CGPoint(x: 0, y: 100).alignedToPixels(forScreenWithScale: 3),
    ]
    let expectedOrigins2 = [
      CGPoint(x: -12.571428571428555, y: 145).alignedToPixels(forScreenWithScale: 3),
      CGPoint(x: -12.571428571428555, y: 145).alignedToPixels(forScreenWithScale: 3),
      CGPoint(x: -12.571428571428555, y: 145).alignedToPixels(forScreenWithScale: 3),
      CGPoint(x: -4, y: 145).alignedToPixels(forScreenWithScale: 3),
    ]
    let expectedOrigins3 = [
      CGPoint(x: 147.14285714285714, y: 80.42857142857142).alignedToPixels(forScreenWithScale: 3),
      CGPoint(x: 147.14285714285714, y: 135.28571428571428).alignedToPixels(forScreenWithScale: 3),
      CGPoint(x: 147.14285714285714, y: 80.42857142857142).alignedToPixels(forScreenWithScale: 3),
      CGPoint(x: 150, y: 89).alignedToPixels(forScreenWithScale: 3),
    ]

    let expectedOrigins4 = [
      CGPoint(x: 147.14285714285714, y: 25.571428571428584).alignedToPixels(forScreenWithScale: 3),
      CGPoint(x: 147.14285714285714, y: 80.42857142857144).alignedToPixels(forScreenWithScale: 3),
      CGPoint(x: 147.14285714285714, y: 135.28571428571428).alignedToPixels(forScreenWithScale: 3),
      CGPoint(x: 150, y: 37).alignedToPixels(forScreenWithScale: 3),
    ]

    let allFrameProviders: [FrameProvider] = [
      verticalFrameProvider,
      verticalPinnedDaysOfWeekFrameProvider,
      verticalPartialMonthFrameProvider,
      horizontalFrameProvider,
    ]

    for (index, frameProvider) in zip(allFrameProviders.indices, allFrameProviders) {
      let monthHeaderLayoutItem = LayoutItem(
        itemType: .monthHeader(Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true)),
        frame: CGRect(x: 0, y: 100, width: 320, height: 50))
      let origin1 = frameProvider.originOfMonth(containing: monthHeaderLayoutItem)
        .alignedToPixels(forScreenWithScale: 3)
      XCTAssert(
        origin1 == expectedOrigins1[index],
        "Incorrect month origin containing month header.")

      let dayOfWeekLayoutItem = LayoutItem(
        itemType: .dayOfWeekInMonth(
          position: .fourth,
          month: Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true)),
        frame: CGRect(x: 130, y: 200, width: 40, height: 40))
      let origin2 = frameProvider.originOfMonth(containing: dayOfWeekLayoutItem)
        .alignedToPixels(forScreenWithScale: 3)
      XCTAssert(
        origin2 == expectedOrigins2[index],
        "Incorrect month origin containing day of week.")

      let dayLayoutItem1 = LayoutItem(
        itemType: .day(
          Day(month: Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true), day: 10)),
        frame: CGRect(x: 200, y: 300, width: 40, height: 40))
      let origin3 = frameProvider.originOfMonth(containing: dayLayoutItem1)
        .alignedToPixels(forScreenWithScale: 3)
      XCTAssert(origin3 == expectedOrigins3[index], "Incorrect month origin containing day.")

      let dayLayoutItem2 = LayoutItem(
        itemType: .day(
          Day(month: Month(era: 1, year: 2020, month: 05, isInGregorianCalendar: true), day: 18)),
        frame: CGRect(x: 200, y: 300, width: 40, height: 40))
      let origin4 = frameProvider.originOfMonth(containing: dayLayoutItem2)
        .alignedToPixels(forScreenWithScale: 3)
      XCTAssert(origin4 == expectedOrigins4[index], "Incorrect month origin containing day.")
    }
  }

  func testPrecedingMonthOrigin() {
    let origin1 = verticalFrameProvider.originOfMonth(
      Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true),
      beforeMonthWithOrigin: CGPoint(x: 0, y: 200))
      .alignedToPixels(forScreenWithScale: 3)
    let expectedOrigin1 = CGPoint(x: 0, y: -189.1428571428571)
      .alignedToPixels(forScreenWithScale: 3)
    XCTAssert(origin1 == expectedOrigin1, "Incorrect origin for preceding month.")

    let origin2 = verticalPinnedDaysOfWeekFrameProvider.originOfMonth(
      Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true),
      beforeMonthWithOrigin: CGPoint(x: 0, y: 400))
      .alignedToPixels(forScreenWithScale: 3)
    let expectedOrigin2 = CGPoint(x: 0, y: 65.71428571428572).alignedToPixels(forScreenWithScale: 3)
    XCTAssert(origin2 == expectedOrigin2, "Incorrect origin for preceding month.")

    let origin3 = verticalPartialMonthFrameProvider.originOfMonth(
      Month(era: 1, year: 2020, month: 05, isInGregorianCalendar: true),
      beforeMonthWithOrigin: CGPoint(x: 0, y: 200))
      .alignedToPixels(forScreenWithScale: 3)
    let expectedOrigin3 = CGPoint(x: 0, y: -134.28571428571428)
      .alignedToPixels(forScreenWithScale: 3)
    XCTAssert(origin3 == expectedOrigin3, "Incorrect origin for preceding month.")

    let origin4 = horizontalFrameProvider.originOfMonth(
      Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true),
      beforeMonthWithOrigin: CGPoint(x: 200, y: 0))
      .alignedToPixels(forScreenWithScale: 3)
    let expectedOrigin4 = CGPoint(x: -120, y: 0).alignedToPixels(forScreenWithScale: 3)
    XCTAssert(origin4 == expectedOrigin4, "Incorrect origin for preceding month.")
  }

  func testSucceedingMonthOrigin() {
    let origin1 = verticalFrameProvider.originOfMonth(
      Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true),
      afterMonthWithOrigin: CGPoint(x: 0, y: 200))
      .alignedToPixels(forScreenWithScale: 3)
    let expectedOrigin1 = CGPoint(x: 0, y: 589.1428571428571)
      .alignedToPixels(forScreenWithScale: 3)
    XCTAssert(origin1 == expectedOrigin1, "Incorrect origin for succeeding month.")

    let origin2 = verticalPinnedDaysOfWeekFrameProvider.originOfMonth(
      Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true),
      afterMonthWithOrigin: CGPoint(x: 0, y: 400))
      .alignedToPixels(forScreenWithScale: 3)
    let expectedOrigin2 = CGPoint(x: 0, y: 734.2857142857142).alignedToPixels(forScreenWithScale: 3)
    XCTAssert(origin2 == expectedOrigin2, "Incorrect origin for succeeding month.")

    let origin3 = verticalPartialMonthFrameProvider.originOfMonth(
      Month(era: 1, year: 2020, month: 06, isInGregorianCalendar: true),
      afterMonthWithOrigin: CGPoint(x: 0, y: 400))
      .alignedToPixels(forScreenWithScale: 3)
    let expectedOrigin3 = CGPoint(x: 0, y: 734.2857142857142).alignedToPixels(forScreenWithScale: 3)
    XCTAssert(origin3 == expectedOrigin3, "Incorrect origin for succeeding month.")

    let origin4 = horizontalFrameProvider.originOfMonth(
      Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true),
      afterMonthWithOrigin: CGPoint(x: 200, y: 0))
      .alignedToPixels(forScreenWithScale: 3)
    let expectedOrigin4 = CGPoint(x: 520, y: 0).alignedToPixels(forScreenWithScale: 3)
    XCTAssert(origin4 == expectedOrigin4, "Incorrect origin for succeeding month.")
  }

  func testFrameOfMonth() {
    let frame1 = verticalFrameProvider.frameOfMonth(
      Month(era: 1, year: 2020, month: 04, isInGregorianCalendar: true),
      withOrigin: CGPoint(x: 0, y: 200))
      .alignedToPixels(forScreenWithScale: 3)
    let expectedFrame1 = CGRect(x: 0.0, y: 200.0, width: 320.0, height: 369.1428571428571)
      .alignedToPixels(forScreenWithScale: 3)
    XCTAssert(frame1 == expectedFrame1, "Incorrect frame for month.")

    let frame2 = verticalPinnedDaysOfWeekFrameProvider.frameOfMonth(
      Month(era: 1, year: 2020, month: 04, isInGregorianCalendar: true),
      withOrigin: CGPoint(x: 0, y: 200))
      .alignedToPixels(forScreenWithScale: 3)
    let expectedFrame2 = CGRect(x: 0.0, y: 200.0, width: 320.0, height: 314.2857142857143)
      .alignedToPixels(forScreenWithScale: 3)
    XCTAssert(frame2 == expectedFrame2, "Incorrect frame for month.")

    let frame3 = verticalPartialMonthFrameProvider.frameOfMonth(
      Month(era: 1, year: 2020, month: 07, isInGregorianCalendar: true),
      withOrigin: CGPoint(x: 0, y: 200))
      .alignedToPixels(forScreenWithScale: 3)
    let expectedFrame3 = CGRect(x: 0.0, y: 200.0, width: 320.0, height: 314.2857142857143)
      .alignedToPixels(forScreenWithScale: 3)
    XCTAssert(frame3 == expectedFrame3, "Incorrect frame for month.")

    let frame4 = horizontalFrameProvider.frameOfMonth(
      Month(era: 1, year: 2020, month: 04, isInGregorianCalendar: true),
      withOrigin: CGPoint(x: 500, y: 0))
      .alignedToPixels(forScreenWithScale: 3)
    let expectedFrame4 = CGRect(x: 500.0, y: 0.0, width: 300.0, height: 352.0)
      .alignedToPixels(forScreenWithScale: 3)
    XCTAssert(frame4 == expectedFrame4, "Incorrect frame for month.")
  }

  // MARK: Core item frame calculations

  func testMonthHeaderFrame() {
    let frame1 = verticalFrameProvider.frameOfMonthHeader(inMonthWithOrigin: CGPoint(x: 0, y: 300))
      .alignedToPixels(forScreenWithScale: 3)
    let expectedFrame1 = CGRect(x: 0, y: 300, width: 320, height: 50)
      .alignedToPixels(forScreenWithScale: 3)
    XCTAssert(frame1 == expectedFrame1, "Incorrect frame for month header.")

    let frame2 = verticalPinnedDaysOfWeekFrameProvider.frameOfMonthHeader(
      inMonthWithOrigin: CGPoint(x: 0, y: 300))
      .alignedToPixels(forScreenWithScale: 3)
    let expectedFrame2 = CGRect(x: 0, y: 300, width: 320, height: 50)
      .alignedToPixels(forScreenWithScale: 3)
    XCTAssert(frame2 == expectedFrame2, "Incorrect frame for month header.")

    let frame3 = horizontalFrameProvider.frameOfMonthHeader(
      inMonthWithOrigin: CGPoint(x: 300, y: 0))
      .alignedToPixels(forScreenWithScale: 3)
    let expectedFrame3 = CGRect(x: 300, y: 0, width: 300, height: 50)
      .alignedToPixels(forScreenWithScale: 3)
    XCTAssert(frame3 == expectedFrame3, "Incorrect frame for month header.")
  }

  func testDayOfWeekFrame() {
    let frame1 = verticalFrameProvider.frameOfDayOfWeek(
      at: .fifth,
      inMonthWithOrigin: CGPoint(x: 0, y: 200))
      .alignedToPixels(forScreenWithScale: 3)
    let expectedFrame1 = CGRect(
      x: 187.42857142857142,
      y: 255,
      width: 34.857142857142854,
      height: 34.857142857142854)
      .alignedToPixels(forScreenWithScale: 3)
    XCTAssert(frame1 == expectedFrame1, "Incorrect frame for day of week.")

    let frame2 = verticalPinnedDaysOfWeekFrameProvider.frameOfDayOfWeek(
      at: .first,
      inMonthWithOrigin: CGPoint(x: 0, y: 200))
      .alignedToPixels(forScreenWithScale: 3)
    let expectedFrame2 = CGRect(x: 8, y: 255, width: 34.857142857142854, height: 34.857142857142854)
      .alignedToPixels(forScreenWithScale: 3)
    XCTAssert(frame2 == expectedFrame2, "Incorrect frame for day of week.")

    let frame3 = horizontalFrameProvider.frameOfDayOfWeek(
      at: .last,
      inMonthWithOrigin: CGPoint(x: 200, y: 0))
      .alignedToPixels(forScreenWithScale: 3)
    let expectedFrame3 = CGRect(x: 460, y: 55, width: 32, height: 32)
      .alignedToPixels(forScreenWithScale: 3)
    XCTAssert(frame3 == expectedFrame3, "Incorrect frame for day of week.")
  }

  func testDayFrameInMonth() {
    let frame1 = verticalFrameProvider.frameOfDay(
      Day(month: Month(era: 1, year: 2020, month: 04, isInGregorianCalendar: true), day: 20),
      inMonthWithOrigin: CGPoint(x: 0, y: 69))
      .alignedToPixels(forScreenWithScale: 3)
    let expectedFrame1 = CGRect(
      x: 52.857142857142854,
      y: 343.42857142857144,
      width: 34.857142857142854,
      height: 34.857142857142854)
      .alignedToPixels(forScreenWithScale: 3)
    XCTAssert(frame1 == expectedFrame1, "Incorrect frame for day.")

    let frame2 = verticalPinnedDaysOfWeekFrameProvider.frameOfDay(
      Day(month: Month(era: 1, year: 1994, month: 01, isInGregorianCalendar: true), day: 01),
      inMonthWithOrigin: CGPoint(x: 0, y: 130))
      .alignedToPixels(forScreenWithScale: 3)
    let expectedFrame2 = CGRect(
      x: 277.1428571428571,
      y: 185,
      width: 34.857142857142854,
      height: 34.857142857142854)
      .alignedToPixels(forScreenWithScale: 3)
    XCTAssert(frame2 == expectedFrame2, "Incorrect frame for day of week.")

    let frame3 = verticalPartialMonthFrameProvider.frameOfDay(
      Day(month: Month(era: 1, year: 2020, month: 05, isInGregorianCalendar: true), day: 29),
      inMonthWithOrigin: CGPoint(x: 0, y: 69))
      .alignedToPixels(forScreenWithScale: 3)
    let expectedFrame3 = CGRect(
      x: 232.28571428571428,
      y: 288.57142857142856,
      width: 34.857142857142854,
      height: 34.857142857142854)
      .alignedToPixels(forScreenWithScale: 3)
    XCTAssert(frame3 == expectedFrame3, "Incorrect frame for day.")

    let frame4 = horizontalFrameProvider.frameOfDay(
      Day(month: Month(era: 1, year: 2072, month: 06, isInGregorianCalendar: true), day: 30),
      inMonthWithOrigin: CGPoint(x: 300, y: 0))
      .alignedToPixels(forScreenWithScale: 3)
    let expectedFrame4 = CGRect(x: 476, y: 315, width: 32, height: 32)
      .alignedToPixels(forScreenWithScale: 3)
    XCTAssert(frame4 == expectedFrame4, "Incorrect frame for day of week.")
  }

  func testAdjacentDayFrame() {
    let middleDay = Day(
      month: Month(era: 1, year: 2020, month: 04, isInGregorianCalendar: true),
      day: 22)
    let middleDayMonthOrigin = CGPoint(x: 0, y: 100)
    let middleDayFrame = verticalFrameProvider.frameOfDay(
      middleDay,
      inMonthWithOrigin: middleDayMonthOrigin)
      .alignedToPixels(forScreenWithScale: 3)
    let frameBeforeMiddleDay = verticalFrameProvider.frameOfDay(
      calendar.day(byAddingDays: -1, to: middleDay),
      adjacentTo: middleDay,
      withFrame: middleDayFrame,
      inMonthWithOrigin: middleDayMonthOrigin)
      .alignedToPixels(forScreenWithScale: 3)
    let frameAfterMiddleDay = verticalFrameProvider.frameOfDay(
      calendar.day(byAddingDays: 1, to: middleDay),
      adjacentTo: middleDay,
      withFrame: middleDayFrame,
      inMonthWithOrigin: middleDayMonthOrigin)
      .alignedToPixels(forScreenWithScale: 3)
    let expectedFrameBeforeMiddleDay = CGRect(
      x: 97.8095238095238,
      y: 374.3333333333333,
      width: 34.857142857142854,
      height: 34.857142857142854)
      .alignedToPixels(forScreenWithScale: 3)
    let expectedFrameAfterMiddleDay = CGRect(
      x: 187.33333333333334,
      y: 374.3333333333333,
      width: 34.857142857142854,
      height: 34.857142857142854)
      .alignedToPixels(forScreenWithScale: 3)
    XCTAssert(frameBeforeMiddleDay == expectedFrameBeforeMiddleDay, "Incorrect frame for day.")
    XCTAssert(frameAfterMiddleDay == expectedFrameAfterMiddleDay, "Incorrect frame for day.")

    let leftDay = Day(
      month: Month(era: 1, year: 2020, month: 04, isInGregorianCalendar: true),
      day: 19)
    let leftDayMonthOrigin = CGPoint(x: 0, y: 200)
    let leftDayFrame = verticalPinnedDaysOfWeekFrameProvider.frameOfDay(
      leftDay,
      inMonthWithOrigin: leftDayMonthOrigin)
      .alignedToPixels(forScreenWithScale: 3)
    let frameBeforeLeftDay = verticalPinnedDaysOfWeekFrameProvider.frameOfDay(
      calendar.day(byAddingDays: -1, to: leftDay),
      adjacentTo: leftDay,
      withFrame: leftDayFrame,
      inMonthWithOrigin: leftDayMonthOrigin)
      .alignedToPixels(forScreenWithScale: 3)
    let frameAfterLeftDay = verticalPinnedDaysOfWeekFrameProvider.frameOfDay(
      calendar.day(byAddingDays: 1, to: leftDay),
      adjacentTo: leftDay,
      withFrame: leftDayFrame,
      inMonthWithOrigin: leftDayMonthOrigin)
      .alignedToPixels(forScreenWithScale: 3)
    let expectedFrameBeforeLeftDay = CGRect(
      x: 277.14285714285717,
      y: 364.80952380952385,
      width: 34.857142857142854,
      height: 34.857142857142854)
      .alignedToPixels(forScreenWithScale: 3)
    let expectedFrameAfterLeftDay = CGRect(
      x: 53.0,
      y: 419.6666666666667,
      width: 34.857142857142854,
      height: 34.857142857142854)
      .alignedToPixels(forScreenWithScale: 3)
    XCTAssert(frameBeforeLeftDay == expectedFrameBeforeLeftDay, "Incorrect frame for day.")
    XCTAssert(frameAfterLeftDay == expectedFrameAfterLeftDay, "Incorrect frame for day.")

    let rightDay = Day(
      month: Month(era: 1, year: 2020, month: 04, isInGregorianCalendar: true),
      day: 25)
    let rightDayMonthOrigin = CGPoint(x: 1000, y: 0)
    let rightDayFrame = horizontalFrameProvider.frameOfDay(
      rightDay,
      inMonthWithOrigin: rightDayMonthOrigin)
      .alignedToPixels(forScreenWithScale: 3)
    let frameBeforeRightDay = horizontalFrameProvider.frameOfDay(
      calendar.day(byAddingDays: -1, to: rightDay),
      adjacentTo: rightDay,
      withFrame: rightDayFrame,
      inMonthWithOrigin: rightDayMonthOrigin)
      .alignedToPixels(forScreenWithScale: 3)
    let frameAfterRightDay = horizontalFrameProvider.frameOfDay(
      calendar.day(byAddingDays: 1, to: rightDay),
      adjacentTo: rightDay,
      withFrame: rightDayFrame,
      inMonthWithOrigin: rightDayMonthOrigin)
      .alignedToPixels(forScreenWithScale: 3)
    let expectedFrameBeforeRightDay = CGRect(
      x: 1218.0,
      y: 263.0,
      width: 32.0,
      height: 32.0)
      .alignedToPixels(forScreenWithScale: 3)
    let expectedFrameAfterRightDay = CGRect(
      x: 1008.0,
      y: 315.0,
      width: 32.0,
      height: 32.0)
      .alignedToPixels(forScreenWithScale: 3)
    XCTAssert(frameBeforeRightDay == expectedFrameBeforeRightDay, "Incorrect frame for day.")
    XCTAssert(frameAfterRightDay == expectedFrameAfterRightDay, "Incorrect frame for day.")
  }

  // MARK: Misc item frame calculations

  func testPinnedDayOfWeekFrame() {
    let frame1 = verticalPinnedDaysOfWeekFrameProvider.frameOfPinnedDayOfWeek(
      at: .second,
      yContentOffset: 275)
      .alignedToPixels(forScreenWithScale: 3)
    let expectedFrame1 = CGRect(
      x: 52.857142857142854,
      y: 275,
      width: 34.857142857142854,
      height: 34.857142857142854)
      .alignedToPixels(forScreenWithScale: 3)
    XCTAssert(frame1 == expectedFrame1, "Incorrect frame for pinned day of week.")
  }

  func testPinnedDaysOfWeekBackgroundFrame() {
    let frame1 = verticalPinnedDaysOfWeekFrameProvider.frameOfPinnedDaysOfWeekRowBackground(
      yContentOffset: 140)
      .alignedToPixels(forScreenWithScale: 3)
    let expectedFrame1 = CGRect(x: 0, y: 140, width: 320, height: 34.857142857142854)
      .alignedToPixels(forScreenWithScale: 3)
    XCTAssert(frame1 == expectedFrame1, "Incorrect frame for pinned days-of-week row background.")
  }

  func testPinnedDaysOfWeekSeparatorFrame() {
    let frame1 = verticalPinnedDaysOfWeekFrameProvider.frameOfPinnedDaysOfWeekRowSeparator(
      yContentOffset: 120,
      separatorHeight: 2)
    let expectedFrame1 = CGRect(x: 0, y: 152.85714285714286, width: 320, height: 2)
    XCTAssert(frame1 == expectedFrame1, "Incorrect frame for pinned day-of-week row separator.")

    let frame2 = verticalFrameProvider.frameOfDaysOfWeekRowSeparator(
      inMonthWithOrigin: CGPoint(x: 0, y: 120),
      separatorHeight: 1)
    let expectedFrame2 = CGRect(x: 0, y: 208.85714285714286, width: 320, height: 1)
    XCTAssert(frame2 == expectedFrame2, "Incorrect frame for day-of-week row separator.")

    let frame3 = horizontalFrameProvider.frameOfDaysOfWeekRowSeparator(
      inMonthWithOrigin: CGPoint(x: 421, y: 0),
      separatorHeight: 10)
    let expectedFrame3 = CGRect(x: 421, y: 77, width: 300, height: 10)
    XCTAssert(frame3 == expectedFrame3, "Incorrect frame for day-of-week row separator.")
  }

  // MARK: Private

  private let calendar = Calendar(identifier: .gregorian)

  private var verticalFrameProvider: FrameProvider!
  private var verticalPinnedDaysOfWeekFrameProvider: FrameProvider!
  private var verticalPartialMonthFrameProvider: FrameProvider!
  private var horizontalFrameProvider: FrameProvider!

}

// MARK: CGSize Pixel Alignment

private extension CGSize {

  // Rounds a `CGSize`'s origin `width` and `height` values so that they're aligned on pixel
  // boundaries for a screen with the provided scale.
  func alignedToPixels(forScreenWithScale scale: CGFloat) -> CGSize {
    CGSize(
      width: width.alignedToPixel(forScreenWithScale: scale),
      height: height.alignedToPixel(forScreenWithScale: scale))
  }

}
