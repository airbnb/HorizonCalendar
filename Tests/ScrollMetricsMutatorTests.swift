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

// MARK: - ScrollMetricsMutatorTests

final class ScrollMetricsMutatorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    verticalScrollMetricsProvider = MockScrollMetricsProvider()
    horizontalScrollMetricsProvider = MockScrollMetricsProvider()

    let initialSize = CGSize(width: 320, height: 480)

    verticalScrollMetricsMutator = ScrollMetricsMutator(
      scrollMetricsProvider: verticalScrollMetricsProvider,
      scrollAxis: .vertical)
    verticalScrollMetricsMutator.setUpInitialMetricsIfNeeded()
    verticalScrollMetricsMutator.updateContentSizePerpendicularToScrollAxis(
      viewportSize: initialSize)

    horizontalScrollMetricsMutator = ScrollMetricsMutator(
      scrollMetricsProvider: horizontalScrollMetricsProvider,
      scrollAxis: .horizontal)
    horizontalScrollMetricsMutator.setUpInitialMetricsIfNeeded()
    horizontalScrollMetricsMutator.updateContentSizePerpendicularToScrollAxis(
      viewportSize: initialSize)
  }

  // MARK: Initial setup

  func testInitialVerticalMetrics() {
    let size = verticalScrollMetricsProvider.size(for: .vertical)
    let offset = verticalScrollMetricsProvider.offset(for: .vertical)
    let topInset = verticalScrollMetricsProvider.startInset(for: .vertical)
    let bottomInset = verticalScrollMetricsProvider.endInset(for: .vertical)

    XCTAssert(size == offset * 3, "Size should be 3x the offset.")
    XCTAssert(topInset == 0, "Top inset should be 0.")
    XCTAssert(bottomInset == 0, "Bottom inset should be 0.")
  }

  func testInitialHorizontalMetrics() {
    let size = horizontalScrollMetricsProvider.size(for: .horizontal)
    let offset = horizontalScrollMetricsProvider.offset(for: .horizontal)
    let leftInset = horizontalScrollMetricsProvider.startInset(for: .horizontal)
    let rightInset = horizontalScrollMetricsProvider.endInset(for: .horizontal)

    XCTAssert(size == offset * 3, "Size should be 3x the offset.")
    XCTAssert(leftInset == 0, "Left inset should be 0.")
    XCTAssert(rightInset == 0, "Right inset should be 0.")
  }

  // MARK: Scroll position looping

  func testScrollPositionLoopingTopToBottom() {
    let lowerBoundForLooping = verticalScrollMetricsProvider.size(for: .vertical) * (1 / 3)
    verticalScrollMetricsProvider.setOffset(to: lowerBoundForLooping - 50, for: .vertical)

    let oldItemOffsetFromOffset = CGFloat(100)
    let oldItem = LayoutItem(
      itemType: .monthHeader(Month(era: 1, year: 2020, month: 1, isInGregorianCalendar: true)),
      frame: CGRect(
        x: 0,
        y: lowerBoundForLooping + oldItemOffsetFromOffset,
        width: 100,
        height: 50))

    let newItem = verticalScrollMetricsMutator.loopOffsetIfNeeded(updatingPositionOf: oldItem)
    let newOffset = verticalScrollMetricsProvider.offset(for: .vertical)
    let expectedOffset = verticalScrollMetricsProvider.size(for: .vertical) * (2 / 3)

    XCTAssert(newOffset == expectedOffset, "Scroll offset did not loop to the correct location.")
    XCTAssert(
      newItem.frame.minY == expectedOffset + oldItemOffsetFromOffset,
      "Layout affecting item's y position was not looped and offset correctly.")
  }

  func testScrollPositionLoopingBottomToTop() {
    let upperBoundForLooping = verticalScrollMetricsProvider.size(for: .vertical) * (2 / 3)
    verticalScrollMetricsProvider.setOffset(to: upperBoundForLooping + 50, for: .vertical)

    let oldItemOffsetFromOffset = CGFloat(100)
    let oldItem = LayoutItem(
      itemType: .monthHeader(Month(era: 1, year: 2020, month: 1, isInGregorianCalendar: true)),
      frame: CGRect(
        x: 0,
        y: upperBoundForLooping - oldItemOffsetFromOffset,
        width: 100,
        height: 50))

    let newItem = verticalScrollMetricsMutator.loopOffsetIfNeeded(updatingPositionOf: oldItem)
    let newOffset = verticalScrollMetricsProvider.offset(for: .vertical)
    let expectedOffset = verticalScrollMetricsProvider.size(for: .vertical) * (1 / 3)

    XCTAssert(newOffset == expectedOffset, "Scroll offset did not loop to the correct location.")
    XCTAssert(
      newItem.frame.minY == expectedOffset - oldItemOffsetFromOffset,
      "Layout affecting item's y position was not looped and offset correctly.")
  }

  func testScrollPositionNotLoopingWhenInMiddleOfVerticalLoopingRegion() {
    let lowerBoundForLooping = verticalScrollMetricsProvider.size(for: .vertical) * (1 / 3)
    let offset = lowerBoundForLooping + 50
    verticalScrollMetricsProvider.setOffset(to: offset, for: .vertical)

    let oldItemOffsetFromOffset = CGFloat(100)
    let oldItem = LayoutItem(
      itemType: .monthHeader(Month(era: 1, year: 2020, month: 1, isInGregorianCalendar: true)),
      frame: CGRect(
        x: 0,
        y: lowerBoundForLooping + oldItemOffsetFromOffset,
        width: 100,
        height: 50))

    let newItem = verticalScrollMetricsMutator.loopOffsetIfNeeded(updatingPositionOf: oldItem)
    let newOffset = verticalScrollMetricsProvider.offset(for: .vertical)

    XCTAssert(
      newOffset == offset,
      "Scroll offset changed despite no looping being necessary.")
    XCTAssert(
      newItem.frame.minY == oldItem.frame.minY,
      "Layout affecting item's y position was changed despite no looping being necessary.")
  }

  func testScrollPositionLoopingLeftToRight() {
    let lowerBoundForLooping = horizontalScrollMetricsProvider.size(for: .horizontal) * (1 / 3)
    horizontalScrollMetricsProvider.setOffset(to: lowerBoundForLooping - 50, for: .horizontal)

    let oldItemOffsetFromOffset = CGFloat(100)
    let oldItem = LayoutItem(
      itemType: .monthHeader(Month(era: 1, year: 2020, month: 1, isInGregorianCalendar: true)),
      frame: CGRect(
        x: lowerBoundForLooping + oldItemOffsetFromOffset,
        y: 0,
        width: 100,
        height: 50))

    let newItem = horizontalScrollMetricsMutator.loopOffsetIfNeeded(updatingPositionOf: oldItem)
    let newOffset = horizontalScrollMetricsProvider.offset(for: .horizontal)
    let expectedOffset = horizontalScrollMetricsProvider.size(for: .horizontal) * (2 / 3)

    XCTAssert(newOffset == expectedOffset, "Scroll offset did not loop to the correct location.")
    XCTAssert(
      newItem.frame.minX == expectedOffset + oldItemOffsetFromOffset,
      "Layout affecting item's x position was not looped and offset correctly.")
  }

  func testScrollPositionLoopingRightToLeft() {
    let upperBoundForLooping = horizontalScrollMetricsProvider.size(for: .horizontal) * (2 / 3)
    horizontalScrollMetricsProvider.setOffset(to: upperBoundForLooping + 50, for: .horizontal)

    let oldItemOffsetFromOffset = CGFloat(100)
    let oldItem = LayoutItem(
      itemType: .monthHeader(Month(era: 1, year: 2020, month: 1, isInGregorianCalendar: true)),
      frame: CGRect(
        x: upperBoundForLooping - oldItemOffsetFromOffset,
        y: 0,
        width: 100,
        height: 50))

    let newItem = horizontalScrollMetricsMutator.loopOffsetIfNeeded(updatingPositionOf: oldItem)
    let newOffset = horizontalScrollMetricsProvider.offset(for: .horizontal)
    let expectedOffset = horizontalScrollMetricsProvider.size(for: .horizontal) * (1 / 3)

    XCTAssert(newOffset == expectedOffset, "Scroll offset did not loop to the correct location.")
    XCTAssert(
      newItem.frame.minX == expectedOffset - oldItemOffsetFromOffset,
      "Layout affecting item's x position was not looped and offset correctly.")
  }

  func testScrollPositionNotLoopingWhenInMiddleOfHorizontalLoopingRegion() {
    let lowerBoundForLooping = horizontalScrollMetricsProvider.size(for: .horizontal) * (1 / 3)
    let offset = lowerBoundForLooping + 50
    horizontalScrollMetricsProvider.setOffset(to: offset, for: .horizontal)

    let oldItemOffsetFromOffset = CGFloat(100)
    let oldItem = LayoutItem(
      itemType: .monthHeader(Month(era: 1, year: 2020, month: 1, isInGregorianCalendar: true)),
      frame: CGRect(
        x: lowerBoundForLooping + oldItemOffsetFromOffset,
        y: 0,
        width: 100,
        height: 50))

    let newItem = horizontalScrollMetricsMutator.loopOffsetIfNeeded(updatingPositionOf: oldItem)
    let newOffset = horizontalScrollMetricsProvider.offset(for: .horizontal)

    XCTAssert(
      newOffset == offset,
      "Scroll offset changed despite no looping being necessary.")
    XCTAssert(
      newItem.frame.minX == oldItem.frame.minX,
      "Layout affecting item's x position was changed despite no looping being necessary.")
  }

  // MARK: Boundary inset setting

  func testNoVerticalBoundariesVisible() {
    let initialOffset = verticalScrollMetricsProvider.offset(for: .vertical)
    let initialTopInset = verticalScrollMetricsProvider.startInset(for: .vertical)
    let initialBottomInset = verticalScrollMetricsProvider.endInset(for: .vertical)

    verticalScrollMetricsMutator.updateScrollBoundaries(
      minimumScrollOffset: nil,
      maximumScrollOffset: nil)

    let finalOffset = verticalScrollMetricsProvider.offset(for: .vertical)
    let finalTopInset = verticalScrollMetricsProvider.startInset(for: .vertical)
    let finalBottomInset = verticalScrollMetricsProvider.endInset(for: .vertical)

    XCTAssert(initialOffset == finalOffset, "Offset changed despite no boundaries being visible.")
    XCTAssert(
      initialTopInset == finalTopInset,
      "Top inset changed despite no boundaries being visible.")
    XCTAssert(
      initialBottomInset == finalBottomInset,
      "Bottom inset changed despite no boundaries being visible.")
  }

  func testTopBoundaryBecomingVisible() {
    let initialOffset = verticalScrollMetricsProvider.offset(for: .vertical)
    let initialBottomInset = verticalScrollMetricsProvider.endInset(for: .vertical)

    let minimumScrollOffset = CGFloat(1000)
    verticalScrollMetricsMutator.updateScrollBoundaries(
      minimumScrollOffset: minimumScrollOffset,
      maximumScrollOffset: nil)

    let finalOffset = verticalScrollMetricsProvider.offset(for: .vertical)
    let finalTopInset = verticalScrollMetricsProvider.startInset(for: .vertical)
    let finalBottomInset = verticalScrollMetricsProvider.endInset(for: .vertical)

    XCTAssert(
      initialOffset == finalOffset,
      "Offset should not change when updating scroll boundaries.")
    XCTAssert(
      finalTopInset == -minimumScrollOffset,
      "Top inset does not equal the negated minimum scroll offset.")
    XCTAssert(
      initialBottomInset == finalBottomInset,
      "Bottom inset should not change unless the maximum scroll offset is set.")
  }

  func testBottomBoundaryBecomingVisible() {
    let initialOffset = verticalScrollMetricsProvider.offset(for: .vertical)
    let initialTopInset = verticalScrollMetricsProvider.startInset(for: .vertical)

    let maximumScrollOffset = CGFloat(3000)
    verticalScrollMetricsMutator.updateScrollBoundaries(
      minimumScrollOffset: nil,
      maximumScrollOffset: maximumScrollOffset)

    let finalOffset = verticalScrollMetricsProvider.offset(for: .vertical)
    let finalTopInset = verticalScrollMetricsProvider.startInset(for: .vertical)
    let finalBottomInset = verticalScrollMetricsProvider.endInset(for: .vertical)

    let size = verticalScrollMetricsProvider.size(for: .vertical)
    let expectedBottomInset = -(size - maximumScrollOffset)

    XCTAssert(
      initialOffset == finalOffset,
      "Offset should not change when updating scroll boundaries.")
    XCTAssert(
      initialTopInset == finalTopInset,
      "Top inset should not change unless the minimum scroll offset is set.")
    XCTAssert(
      finalBottomInset == expectedBottomInset,
      "Bottom inset does not equal the negated size minus maximum scroll offset.")
  }

  func testTopAndBottomBoundaryBecomingVisible() {
    let initialOffset = verticalScrollMetricsProvider.offset(for: .vertical)

    let minimumScrollOffset = CGFloat(1000)
    let maximumScrollOffset = CGFloat(3000)
    verticalScrollMetricsMutator.updateScrollBoundaries(
      minimumScrollOffset: minimumScrollOffset,
      maximumScrollOffset: maximumScrollOffset)

    let finalOffset = verticalScrollMetricsProvider.offset(for: .vertical)
    let finalTopInset = verticalScrollMetricsProvider.startInset(for: .vertical)
    let finalBottomInset = verticalScrollMetricsProvider.endInset(for: .vertical)

    let size = verticalScrollMetricsProvider.size(for: .vertical)
    let expectedBottomInset = -(size - maximumScrollOffset)

    XCTAssert(
      initialOffset == finalOffset,
      "Offset should not change when updating scroll boundaries.")
    XCTAssert(
      finalTopInset == -minimumScrollOffset,
      "Top inset does not equal the negated minimum scroll offset.")
    XCTAssert(
      finalBottomInset == expectedBottomInset,
      "Bottom inset does not equal the negated size minus maximum scroll offset.")
  }

  func testNoHorizontalBoundariesVisible() {
    let initialOffset = horizontalScrollMetricsProvider.offset(for: .horizontal)
    let initialLeftInset = horizontalScrollMetricsProvider.startInset(for: .horizontal)
    let initialRightInset = horizontalScrollMetricsProvider.endInset(for: .horizontal)

    horizontalScrollMetricsMutator.updateScrollBoundaries(
      minimumScrollOffset: nil,
      maximumScrollOffset: nil)

    let finalOffset = horizontalScrollMetricsProvider.offset(for: .horizontal)
    let finalLeftInset = horizontalScrollMetricsProvider.startInset(for: .horizontal)
    let finalRightInset = horizontalScrollMetricsProvider.endInset(for: .horizontal)

    XCTAssert(initialOffset == finalOffset, "Offset changed despite no boundaries being visible.")
    XCTAssert(
      initialLeftInset == finalLeftInset,
      "Left inset changed despite no boundaries being visible.")
    XCTAssert(
      initialRightInset == finalRightInset,
      "Right inset changed despite no boundaries being visible.")
  }

  func testLeftBoundaryBecomingVisible() {
    let initialOffset = horizontalScrollMetricsProvider.offset(for: .horizontal)
    let initialRightInset = horizontalScrollMetricsProvider.endInset(for: .horizontal)

    let minimumScrollOffset = CGFloat(1000)
    horizontalScrollMetricsMutator.updateScrollBoundaries(
      minimumScrollOffset: minimumScrollOffset,
      maximumScrollOffset: nil)

    let finalOffset = horizontalScrollMetricsProvider.offset(for: .horizontal)
    let finalLeftInset = horizontalScrollMetricsProvider.startInset(for: .horizontal)
    let finalRightInset = horizontalScrollMetricsProvider.endInset(for: .horizontal)

    XCTAssert(
      initialOffset == finalOffset,
      "Offset should not change when updating scroll boundaries.")
    XCTAssert(
      finalLeftInset == -minimumScrollOffset,
      "Left inset does not equal the negated minimum scroll offset.")
    XCTAssert(
      initialRightInset == finalRightInset,
      "Right inset should not change unless the maximum scroll offset is set.")
  }

  func testRightBoundaryBecomingVisible() {
    let initialOffset = horizontalScrollMetricsProvider.offset(for: .horizontal)
    let initialLeftInset = horizontalScrollMetricsProvider.startInset(for: .horizontal)

    let maximumScrollOffset = CGFloat(3000)
    horizontalScrollMetricsMutator.updateScrollBoundaries(
      minimumScrollOffset: nil,
      maximumScrollOffset: maximumScrollOffset)

    let finalOffset = horizontalScrollMetricsProvider.offset(for: .horizontal)
    let finalLeftInset = horizontalScrollMetricsProvider.startInset(for: .horizontal)
    let finalRightInset = horizontalScrollMetricsProvider.endInset(for: .horizontal)

    let size = horizontalScrollMetricsProvider.size(for: .horizontal)
    let expectedRightInset = -(size - maximumScrollOffset)

    XCTAssert(
      initialOffset == finalOffset,
      "Offset should not change when updating scroll boundaries.")
    XCTAssert(
      initialLeftInset == finalLeftInset,
      "Left inset should not change unless the minimum scroll offset is set.")
    XCTAssert(
      finalRightInset == expectedRightInset,
      "Right inset does not equal the negated size minus maximum scroll offset.")
  }

  func testLeftAndRightBoundaryBecomingVisible() {
    let initialOffset = horizontalScrollMetricsProvider.offset(for: .horizontal)

    let minimumScrollOffset = CGFloat(1000)
    let maximumScrollOffset = CGFloat(3000)
    horizontalScrollMetricsMutator.updateScrollBoundaries(
      minimumScrollOffset: minimumScrollOffset,
      maximumScrollOffset: maximumScrollOffset)

    let finalOffset = horizontalScrollMetricsProvider.offset(for: .horizontal)
    let finalLeftInset = horizontalScrollMetricsProvider.startInset(for: .horizontal)
    let finalRightInset = horizontalScrollMetricsProvider.endInset(for: .horizontal)

    let size = horizontalScrollMetricsProvider.size(for: .horizontal)
    let expectedRightInset = -(size - maximumScrollOffset)

    XCTAssert(
      initialOffset == finalOffset,
      "Offset should not change when updating scroll boundaries.")
    XCTAssert(
      finalLeftInset == -minimumScrollOffset,
      "Left inset does not equal the negated minimum scroll offset.")
    XCTAssert(
      finalRightInset == expectedRightInset,
      "Right inset does not equal the negated size minus maximum scroll offset.")
  }

  // MARK: Scroll position offsetting

  func testVerticalOffsetAdjustments() {
    let initialOffset = verticalScrollMetricsProvider.offset(for: .vertical)
    verticalScrollMetricsMutator.applyOffset(500)
    XCTAssert(
      initialOffset + 500 == verticalScrollMetricsProvider.offset(for: .vertical),
      "Scroll offset does not equal the initial offset + 500.")

    let initialOffset2 = verticalScrollMetricsProvider.offset(for: .vertical)
    verticalScrollMetricsMutator.applyOffset(-30)
    XCTAssert(
      initialOffset2 - 30 == verticalScrollMetricsProvider.offset(for: .vertical),
      "Scroll offset does not equal the initial offset - 30.")
  }

  func testHorizontalOffsetAdjustments() {
    let initialOffset = horizontalScrollMetricsProvider.offset(for: .horizontal)
    horizontalScrollMetricsMutator.applyOffset(25)
    XCTAssert(
      initialOffset + 25 == horizontalScrollMetricsProvider.offset(for: .horizontal),
      "Scroll offset does not equal the initial offset + 25.")

    let initialOffset2 = horizontalScrollMetricsProvider.offset(for: .horizontal)
    horizontalScrollMetricsMutator.applyOffset(-1000)
    XCTAssert(
      initialOffset2 - 1000 == horizontalScrollMetricsProvider.offset(for: .horizontal),
      "Scroll offset does not equal the initial offset - 1000.")
  }

  // MARK: Private

  private var verticalScrollMetricsProvider: MockScrollMetricsProvider!
  private var horizontalScrollMetricsProvider: MockScrollMetricsProvider!

  private var verticalScrollMetricsMutator: ScrollMetricsMutator!
  private var horizontalScrollMetricsMutator: ScrollMetricsMutator!

}

// MARK: - MockScrollMetricsProvider

private final class MockScrollMetricsProvider: ScrollMetricsProvider {

  // MARK: Internal

  func size(for scrollAxis: ScrollAxis) -> CGFloat {
    switch scrollAxis {
    case .vertical: return contentSize.height
    case .horizontal: return contentSize.width
    }
  }

  func setSize(to size: CGFloat, for scrollAxis: ScrollAxis) {
    switch scrollAxis {
    case .vertical: contentSize.height = size
    case .horizontal: contentSize.width = size
    }
  }

  func offset(for scrollAxis: ScrollAxis) -> CGFloat {
    switch scrollAxis {
    case .vertical: return contentOffset.y
    case .horizontal: return contentOffset.x
    }
  }

  func setOffset(to offset: CGFloat, for scrollAxis: ScrollAxis) {
    switch scrollAxis {
    case .vertical: contentOffset.y = offset
    case .horizontal: contentOffset.x = offset
    }
  }

  func startInset(for scrollAxis: ScrollAxis) -> CGFloat {
    switch scrollAxis {
    case .vertical: return contentInset.top
    case .horizontal: return contentInset.left
    }
  }

  func setStartInset(to inset: CGFloat, for scrollAxis: ScrollAxis) {
    switch scrollAxis {
    case .vertical: contentInset.top = inset
    case .horizontal: contentInset.left = inset
    }
  }

  func endInset(for scrollAxis: ScrollAxis) -> CGFloat {
    switch scrollAxis {
    case .vertical: return contentInset.bottom
    case .horizontal: return contentInset.right
    }
  }

  func setEndInset(to inset: CGFloat, for scrollAxis: ScrollAxis) {
    switch scrollAxis {
    case .vertical: contentInset.bottom = inset
    case .horizontal: contentInset.right = inset
    }
  }

  // MARK: Private

  private var contentSize = CGSize(width: 100, height: 100)
  private var contentOffset = CGPoint(x: 1, y: -1)
  private var contentInset = UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4)

}
