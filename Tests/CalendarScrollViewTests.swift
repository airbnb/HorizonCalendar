// Created by Andy Bartholomew on 8/12/26.
// Copyright © 2026 Airbnb Inc. All rights reserved.

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

// MARK: - CalendarScrollViewTests

final class CalendarScrollViewTests: XCTestCase {

  // MARK: Internal

  func testAccessibilityElementsIgnoresSubviewsThatAreNotItemViews() {
    let scrollView = CalendarScrollView()
    let itemView = itemView(for: .monthHeader(month))
    scrollView.addSubview(itemView)

    // UIKit adds subviews of its own on some OS versions - `_UITouchPassthroughView`s on iOS 27, for
    // example - which must not prevent the item views from being returned.
    scrollView.addSubview(UIView())

    XCTAssertEqual(scrollView.accessibilityElements?.count, 1)
    XCTAssert(scrollView.accessibilityElements?.first as? ItemView === itemView)
  }

  func testAccessibilityElementsWithNoItemViews() {
    let scrollView = CalendarScrollView()
    scrollView.addSubview(UIView())

    XCTAssertEqual(scrollView.accessibilityElements?.count, 0)
  }

  // MARK: Private

  private let month = Month(era: 1, year: 2026, month: 08, isInGregorianCalendar: true)

  private func itemView(for itemType: LayoutItem.ItemType) -> ItemView {
    let itemView = ItemView(initialCalendarItemModel: MockCalendarItemModel())
    itemView.itemType = .layoutItemType(itemType)
    return itemView
  }

}

// MARK: - MockCalendarItemModel

private struct MockCalendarItemModel: AnyCalendarItemModel {

  var _itemViewDifferentiator = _CalendarItemViewDifferentiator(
    viewType: ObjectIdentifier(UIView.self),
    invariantViewProperties: AnyHashable(0)
  )

  func _makeView() -> UIView {
    UIView()
  }

  func _setContent(onViewOfSameType _: UIView) { }

  func _isContentEqual(toContentOf _: AnyCalendarItemModel) -> Bool {
    false
  }

  mutating func _setSwiftUIWrapperViewContentIDIfNeeded(_: AnyHashable) { }

}
