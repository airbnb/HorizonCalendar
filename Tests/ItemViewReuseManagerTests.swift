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
    let visibleItems: Set<VisibleCalendarItem> = [
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant0),
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant0),
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant1),
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant1),
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
    ]

    reuseManager.viewsForVisibleItems(
      visibleItems,
      viewHandler: { _, _, previousBackingItem in
        XCTAssert(
          previousBackingItem == nil,
          "Previous backing item should be nil since there are no views to reuse.")
      })
  }

  func testReusingIdenticalViews() {
    let initialVisibleItems: Set<VisibleCalendarItem> = [
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant0),
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant0),
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant1),
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant1),
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
    ]

    let subsequentVisibleItems = initialVisibleItems

    // Populate the reuse manager with the initial visible items
    reuseManager.viewsForVisibleItems(initialVisibleItems, viewHandler: { _, _, _ in })

    // Ensure all views are reused by using the exact same previous views
    reuseManager.viewsForVisibleItems(
      subsequentVisibleItems,
      viewHandler: { _, item, previousBackingItem in
        XCTAssert(
          item == previousBackingItem,
          """
            Expected the new item to be identical to the previous backing item, since the subsequent
            visible items are identical to the initial visible items.
          """)
      })
  }

  func testReusingAllViews() {
    let initialVisibleItems: Set<VisibleCalendarItem> = [
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant0),
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant0),
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant1),
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant1),
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
    ]

    let subsequentVisibleItems: Set<VisibleCalendarItem> = [
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant0),
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant0),
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 03, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant1),
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 03, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant1),
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 04, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
    ]

    // Populate the reuse manager with the initial visible items
    reuseManager.viewsForVisibleItems(initialVisibleItems, viewHandler: { _, _, _ in })

    // Ensure all views are reused given the subsequent visible items
    reuseManager.viewsForVisibleItems(
      subsequentVisibleItems,
      viewHandler: { _, item, previousBackingItem in
        XCTAssert(
          item.calendarItemModel.itemViewDifferentiator == previousBackingItem?.calendarItemModel.itemViewDifferentiator,
          """
            Expected the new item to have the same view differentiator as the previous backing item,
            since it was reused.
          """)
      })
  }

  func testReusingSomeViews() {
    let initialVisibleItems: Set<VisibleCalendarItem> = [
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant0),
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant0),
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant1),
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant1),
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant2),
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant3),
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
    ]

    let subsequentVisibleItems: Set<VisibleCalendarItem> = [
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant1),
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 05, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant3),
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 05, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant4),
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 04, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant5),
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 05, isInGregorianCalendar: true))),
        frame: .zero),
    ]

    // Populate the reuse manager with the initial visible items
    reuseManager.viewsForVisibleItems(initialVisibleItems, viewHandler: { _, _, _ in })

    // Ensure the correct subset of views are reused given the subsequent visible items
    reuseManager.viewsForVisibleItems(
      subsequentVisibleItems,
      viewHandler: { _, item, previousBackingItem in
        guard
          case .itemModel(let opaqueCalendarItemModel) = item.calendarItemModel,
          let itemModel = opaqueCalendarItemModel as? MockCalendarItemModel
        else
        {
          preconditionFailure(
            "Failed to convert the calendar item model to an instance of MockCalendarItemModel.")
        }

        switch itemModel {
        case .variant1, .variant3:
          XCTAssert(
            item.calendarItemModel.itemViewDifferentiator == previousBackingItem?.calendarItemModel.itemViewDifferentiator,
            """
              Expected the new item to have the same reuse identifier as the previous backing item,
              since it was reused.
            """)
        default:
          XCTAssert(
            previousBackingItem == nil,
            "Previous backing item should be nil since there are no views to reuse.")
        }
      })
  }

  func testDepletingAvailableReusableViews() {
    let initialVisibleItems: Set<VisibleCalendarItem> = [
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant0),
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant0),
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant1),
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 01, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant1),
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 02, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant1),
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 03, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
    ]

    let subsequentVisibleItems: Set<VisibleCalendarItem> = [
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant0),
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 03, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant0),
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 04, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant0),
        itemType: .layoutItemType(
          .monthHeader(Month(era: 1, year: 2020, month: 05, isInGregorianCalendar: true))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant1),
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 03, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant1),
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 04, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant1),
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 05, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant1),
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 06, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant1),
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 07, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
      .init(
        calendarItemModel: .itemModel(MockCalendarItemModel.variant2),
        itemType: .layoutItemType(
          .day(
            Day(
              month: Month(era: 1, year: 2020, month: 07, isInGregorianCalendar: true),
              day: 01))),
        frame: .zero),
    ]

    // Populate the reuse manager with the initial visible items
    reuseManager.viewsForVisibleItems(initialVisibleItems, viewHandler: { _, _, _ in })

    // Ensure the correct subset of views are reused given the subsequent visible items
    var reuseCountsForDifferentiators = [_CalendarItemViewDifferentiator: Int]()
    var newViewCountsForDifferentiators = [_CalendarItemViewDifferentiator: Int]()
    reuseManager.viewsForVisibleItems(
      subsequentVisibleItems,
      viewHandler: { _, item, previousBackingItem in
        if previousBackingItem != nil {
          let reuseCount = (reuseCountsForDifferentiators[item.calendarItemModel.itemViewDifferentiator] ?? 0) + 1
          reuseCountsForDifferentiators[item.calendarItemModel.itemViewDifferentiator] = reuseCount
        } else {
          let newViewCount = (newViewCountsForDifferentiators[item.calendarItemModel.itemViewDifferentiator] ?? 0) + 1
          newViewCountsForDifferentiators[item.calendarItemModel.itemViewDifferentiator] = newViewCount
        }
      })

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

  // MARK: Private

  private var reuseManager: ItemViewReuseManager!

}

// MARK: - MockCalendarItemModel

private struct MockCalendarItemModel: AnyCalendarItemModel, Equatable {

  // MARK: Lifecycle

  init(
    viewRepresentableTypeDescription: String,
    viewTypeDescription: String,
    invariantViewProperties: AnyHashable)
  {
    _itemViewDifferentiator = .viewRepresentable(
      viewRepresentableTypeDescription: viewRepresentableTypeDescription,
      viewTypeDescription: viewTypeDescription,
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
    viewRepresentableTypeDescription: "ViewRepresentingA",
    viewTypeDescription: "UIView",
    invariantViewProperties: InvariantViewProperties(font: .systemFont(ofSize: 12), color: .white))
  static let variant1 = MockCalendarItemModel(
    viewRepresentableTypeDescription: "ViewRepresentingA",
    viewTypeDescription: "UIView",
    invariantViewProperties: InvariantViewProperties(font: .systemFont(ofSize: 14), color: .white))
  static let variant2 = MockCalendarItemModel(
    viewRepresentableTypeDescription: "ViewRepresentingA",
    viewTypeDescription: "UIView",
    invariantViewProperties: InvariantViewProperties(font: .systemFont(ofSize: 14), color: .black))
  static let variant3 = MockCalendarItemModel(
    viewRepresentableTypeDescription: "LabelRepresentingA",
    viewTypeDescription: "UILabel",
    invariantViewProperties: InvariantLabelPropertiesA(font: .systemFont(ofSize: 14), color: .red))
  static let variant4 = MockCalendarItemModel(
    viewRepresentableTypeDescription: "LabelRepresentingB",
    viewTypeDescription: "UILabel",
    invariantViewProperties: InvariantLabelPropertiesB(font: .systemFont(ofSize: 16), color: .red))
  static let variant5 = MockCalendarItemModel(
    viewRepresentableTypeDescription: "LabelRepresentingB",
    viewTypeDescription: "UILabel",
    invariantViewProperties: InvariantLabelPropertiesB(font: .systemFont(ofSize: 16), color: .blue))

  var _itemViewDifferentiator: _CalendarItemViewDifferentiator

  func _makeView() -> UIView {
    UIView()
  }

  func _setViewModel(onViewOfSameType view: UIView) { }

  func _isViewModel(equalToViewModelOf other: AnyCalendarItemModel) -> Bool {
    false
  }

}
