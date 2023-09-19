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
    verticalScrollMetricsProvider = Self.mockScrollMetricsProvider()
    horizontalScrollMetricsProvider = Self.mockScrollMetricsProvider()

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

  // MARK: Scroll Boundary Offsets

  func testVerticalMinimumScrollOffset() {
    verticalScrollMetricsProvider.setStartInset(to: 100, for: .vertical)
    XCTAssert(
      verticalScrollMetricsProvider.minimumOffset(for: .vertical) == -100,
      "The minimum offset should equal the negated top inset.")
  }

  func testHorizontalMinimumScrollOffset() {
    horizontalScrollMetricsProvider.setStartInset(to: 300, for: .horizontal)
    XCTAssert(
      horizontalScrollMetricsProvider.minimumOffset(for: .horizontal) == -300,
      "The minimum offset should equal the negated left inset.")
  }

  func testVerticalMaximumScrollOffset() {
    verticalScrollMetricsProvider.setEndInset(to: -50, for: .vertical)
    XCTAssert(
      verticalScrollMetricsProvider.maximumOffset(for: .vertical) == 9999999999470.0,
      "The maximum offset should equal the content height plus bottom inset minus bounds height.")
  }

  func testHorizontalMaximumScrollOffset() {
    horizontalScrollMetricsProvider.setEndInset(to: -80, for: .horizontal)
    XCTAssert(
      horizontalScrollMetricsProvider.maximumOffset(for: .horizontal) == 9999999999600.0,
      "The maximum offset should equal the content width plus right inset minus bounds width.")
  }

  // MARK: Private

  // swiftlint:disable implicitly_unwrapped_optional

  private var verticalScrollMetricsProvider: ScrollMetricsProvider!
  private var horizontalScrollMetricsProvider: ScrollMetricsProvider!

  private var verticalScrollMetricsMutator: ScrollMetricsMutator!
  private var horizontalScrollMetricsMutator: ScrollMetricsMutator!

  private static func mockScrollMetricsProvider() -> ScrollMetricsProvider {
    let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
    scrollView.contentInsetAdjustmentBehavior = .never
    scrollView.contentSize = CGSize(width: 10, height: 10)
    scrollView.contentOffset = CGPoint(x: 1, y: -1)
    scrollView.contentInset = UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4)
    return scrollView
  }

}
