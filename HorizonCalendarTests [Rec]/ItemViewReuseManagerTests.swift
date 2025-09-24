// Created by Bryan Keller on 3/26/20.
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

// MARK: - ItemViewReuseManagerTests

final class ItemViewReuseManagerTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    reuseManager = ItemViewReuseManager()
  }

  func testInitialViewCreationWithNoReuse() {
    let visibleItems: Set<VisibleItem> = [
      .init(
        calendarItemModel: MockCalendarItemModel.variant0,
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant0,
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant1,
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant1,
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
    ]

    let contexts = reuseManager.reusedViewContexts(
      visibleItems: visibleItems,
      reuseUnusedViews: true)
    for context in contexts {
      XCTAssert(
        !context.isViewReused,
        "isViewReused should be false since there are no views to reuse.")
      XCTAssert(
        !context.isReusedViewSameAsPreviousView,
        "isReusedViewSameAsPreviousView should be false when no view was reused.")
    }
  }

  func testReusingIdenticalViews() {
    let initialVisibleItems: Set<VisibleItem> = [
      .init(
        calendarItemModel: MockCalendarItemModel.variant0,
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant0,
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant1,
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant1,
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
    ]

    let subsequentVisibleItems = initialVisibleItems

    // Populate the reuse manager with the initial visible items
    let _ = reuseManager.reusedViewContexts(
      visibleItems: initialVisibleItems,
      reuseUnusedViews: true)

    // Ensure all views are reused by using the exact same previous views
    let contexts = reuseManager.reusedViewContexts(
      visibleItems: subsequentVisibleItems,
      reuseUnusedViews: true)
    for context in contexts {
      XCTAssert(
        context.isViewReused,
        """
          Expected every view to be reused, since the subsequent visible items are identical to the
          initial visible items.
        """)
      XCTAssert(
        context.isReusedViewSameAsPreviousView,
        "isReusedViewSameAsPreviousView should be true when the same view was reused.")
    }
  }

  func testReusingAllViews() {
    let initialVisibleItems: Set<VisibleItem> = [
      .init(
        calendarItemModel: MockCalendarItemModel.variant0,
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant0,
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant1,
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant1,
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
    ]

    let subsequentVisibleItems: Set<VisibleItem> = [
      .init(
        calendarItemModel: MockCalendarItemModel.variant0,
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant0,
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 03, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant1,
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 03, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant1,
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 04, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
    ]

    // Populate the reuse manager with the initial visible items
    let _ = reuseManager.reusedViewContexts(
      visibleItems: initialVisibleItems,
      reuseUnusedViews: true)

    // Allow the reuse manager to figure out which items are reusable
    let _ = reuseManager.reusedViewContexts(
      visibleItems: [],
      reuseUnusedViews: true)

    // Ensure all views are reused given the subsequent visible items
    let contexts = reuseManager.reusedViewContexts(
      visibleItems: subsequentVisibleItems,
      reuseUnusedViews: true)
    for context in contexts {
      XCTAssert(context.isViewReused, "Expected every view to be reused")
    }
  }

  func testReusingSomeViews() {
    let initialVisibleItems: Set<VisibleItem> = [
      .init(
        calendarItemModel: MockCalendarItemModel.variant0,
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant0,
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant1,
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant1,
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant2,
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant3,
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
    ]

    let subsequentVisibleItems: Set<VisibleItem> = [
      .init(
        calendarItemModel: MockCalendarItemModel.variant1,
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 05, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant3,
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 05, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant4,
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 04, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant5,
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 05, isInGregorianCalendar: true))),
        frame: .zero),
    ]

    // Populate the reuse manager with the initial visible items
    let _ = reuseManager.reusedViewContexts(
      visibleItems: initialVisibleItems,
      reuseUnusedViews: true)

    // Allow the reuse manager to figure out which items are reusable
    let _ = reuseManager.reusedViewContexts(
      visibleItems: [],
      reuseUnusedViews: true)

    // Ensure the correct subset of views are reused given the subsequent visible items
    let contexts = reuseManager.reusedViewContexts(
      visibleItems: subsequentVisibleItems,
      reuseUnusedViews: true)
    for context in contexts {
      guard let itemModel = context.visibleItem.calendarItemModel as? MockCalendarItemModel else {
        preconditionFailure(
          "Failed to convert the calendar item model to an instance of MockCalendarItemModel.")
      }

      switch itemModel {
      case .variant1, .variant3:
        XCTAssert(
          context.isViewReused,
          "isViewReused should be true since it was reused.")
        XCTAssert(
          !context.isReusedViewSameAsPreviousView,
          "isReusedViewSameAsPreviousView should be false when a different view was reused.")
      default:
        XCTAssert(
          !context.isViewReused,
          "isViewReused should be false since there are no views to reuse.")
        XCTAssert(
          !context.isReusedViewSameAsPreviousView,
          "isReusedViewSameAsPreviousView should be false when a different view was reused.")
      }
    }
  }

  func testDepletingAvailableReusableViews() {
    let initialVisibleItems: Set<VisibleItem> = [
      .init(
        calendarItemModel: MockCalendarItemModel.variant0,
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant0,
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant1,
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant1,
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant1,
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 03, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
    ]

    let subsequentVisibleItems: Set<VisibleItem> = [
      .init(
        calendarItemModel: MockCalendarItemModel.variant0,
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 03, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant0,
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 04, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant0,
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 05, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant1,
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 03, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant1,
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 04, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant1,
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 05, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant1,
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 06, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant1,
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 07, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant2,
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 07, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
    ]

    // Populate the reuse manager with the initial visible items
    let _ = reuseManager.reusedViewContexts(
      visibleItems: initialVisibleItems,
      reuseUnusedViews: true)

    // Allow the reuse manager to figure out which items are reusable
    let _ = reuseManager.reusedViewContexts(
      visibleItems: [],
      reuseUnusedViews: true)

    // Ensure the correct subset of views are reused given the subsequent visible items
    var reuseCountsForDifferentiators = [_CalendarItemViewDifferentiator: Int]()
    var newViewCountsForDifferentiators = [_CalendarItemViewDifferentiator: Int]()
    let contexts = reuseManager.reusedViewContexts(
      visibleItems: subsequentVisibleItems,
      reuseUnusedViews: true)
    for context in contexts {
      let item = context.visibleItem
      if context.isViewReused {
        let reuseCount = (reuseCountsForDifferentiators[item.calendarItemModel._itemViewDifferentiator] ?? 0) + 1
        reuseCountsForDifferentiators[item.calendarItemModel._itemViewDifferentiator] = reuseCount
      } else {
        let newViewCount = (newViewCountsForDifferentiators[item.calendarItemModel._itemViewDifferentiator] ?? 0) + 1
        newViewCountsForDifferentiators[item.calendarItemModel._itemViewDifferentiator] = newViewCount
      }
    }

    let expectedReuseCountsForDifferentiators: [_CalendarItemViewDifferentiator: Int] = [
      MockCalendarItemModel.variant0._itemViewDifferentiator: 2,
      MockCalendarItemModel.variant1._itemViewDifferentiator: 3,
    ]
    let expectedNewViewCountsForDifferentiators: [_CalendarItemViewDifferentiator: Int] = [
      MockCalendarItemModel.variant0._itemViewDifferentiator: 1,
      MockCalendarItemModel.variant1._itemViewDifferentiator: 2,
      MockCalendarItemModel.variant2._itemViewDifferentiator: 1,
    ]

    XCTAssert(
      reuseCountsForDifferentiators == expectedReuseCountsForDifferentiators,
      "The number of reuses does not match the expected number of reuses.")

    XCTAssert(
      newViewCountsForDifferentiators == expectedNewViewCountsForDifferentiators,
      "The number of new view creations does not match the expected number of new view creations.")
  }

  func testDisablingViewRecycling() {
    let initialVisibleItems: Set<VisibleItem> = [
      .init(
        calendarItemModel: MockCalendarItemModel.variant0,
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant0,
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant1,
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant1,
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant2,
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant3,
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
    ]

    let subsequentVisibleItems: Set<VisibleItem> = [
      .init(
        calendarItemModel: MockCalendarItemModel.variant1,
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 05, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant3,
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 05, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant4,
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 04, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: MockCalendarItemModel.variant5,
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 05, isInGregorianCalendar: true))),
        frame: .zero),
    ]

    // Populate the reuse manager with the initial visible items
    let _ = reuseManager.reusedViewContexts(
      visibleItems: initialVisibleItems,
      reuseUnusedViews: false)

    // Ensure the correct subset of views are reused given the subsequent visible items
    let contexts = reuseManager.reusedViewContexts(
      visibleItems: subsequentVisibleItems,
      reuseUnusedViews: false)
    for context in contexts {
      guard let itemModel = context.visibleItem.calendarItemModel as? MockCalendarItemModel else {
        preconditionFailure(
          "Failed to convert the calendar item model to an instance of MockCalendarItemModel.")
      }

      switch itemModel {
      case .variant1, .variant3:
        XCTAssert(
          !context.isViewReused,
          "isViewReused should be false since view recycling is disabled.")
        XCTAssert(
          !context.isReusedViewSameAsPreviousView,
          "isReusedViewSameAsPreviousView should be false when a different view was reused.")
      default:
        XCTAssert(
          !context.isViewReused,
          "isViewReused should be false since there are no views to reuse.")
        XCTAssert(
          !context.isReusedViewSameAsPreviousView,
          "isReusedViewSameAsPreviousView should be false when a different view was reused.")
      }
    }
  }

  // MARK: Private

  // swiftlint:disable:next implicitly_unwrapped_optional
  private var reuseManager: ItemViewReuseManager!

}

// MARK: - MockCalendarItemModel

private struct MockCalendarItemModel: AnyCalendarItemModel, Equatable {

  // MARK: Lifecycle

  init(
    viewType: ObjectIdentifier,
    invariantViewProperties: AnyHashable)
  {
    _itemViewDifferentiator = _CalendarItemViewDifferentiator(
      viewType: viewType,
      invariantViewProperties: invariantViewProperties)
  }

  // MARK: Internal

  struct InvariantViewProperties: Hashable {
    let font: UIFont
    let color: UIColor
  }

  struct InvariantLabelPropertiesA: Hashable {
    let font: UIFont
    let color: UIColor
  }

  struct InvariantLabelPropertiesB: Hashable {
    let font: UIFont
    let color: UIColor
  }

  static let variant0 = MockCalendarItemModel(
    viewType: ObjectIdentifier(UIView.self),
    invariantViewProperties: InvariantViewProperties(font: .systemFont(ofSize: 12), color: .white))
  static let variant1 = MockCalendarItemModel(
    viewType: ObjectIdentifier(UIView.self),
    invariantViewProperties: InvariantViewProperties(font: .systemFont(ofSize: 14), color: .white))
  static let variant2 = MockCalendarItemModel(
    viewType: ObjectIdentifier(UIView.self),
    invariantViewProperties: InvariantViewProperties(font: .systemFont(ofSize: 14), color: .black))
  static let variant3 = MockCalendarItemModel(
    viewType: ObjectIdentifier(UILabel.self),
    invariantViewProperties: InvariantLabelPropertiesA(font: .systemFont(ofSize: 14), color: .red))
  static let variant4 = MockCalendarItemModel(
    viewType: ObjectIdentifier(UILabel.self),
    invariantViewProperties: InvariantLabelPropertiesB(font: .systemFont(ofSize: 16), color: .red))
  static let variant5 = MockCalendarItemModel(
    viewType: ObjectIdentifier(UILabel.self),
    invariantViewProperties: InvariantLabelPropertiesB(font: .systemFont(ofSize: 16), color: .blue))

  var _itemViewDifferentiator: _CalendarItemViewDifferentiator

  func _makeView() -> UIView {
    UIView()
  }

  func _setContent(onViewOfSameType _: UIView) { }

  func _isContentEqual(toContentOf _: AnyCalendarItemModel) -> Bool {
    false
  }

  mutating func _setSwiftUIWrapperViewContentIDIfNeeded(_: AnyHashable) { }

}
