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

// MARK: - ScreenPixelAlignmentTests

final class ScreenPixelAlignmentTests: XCTestCase {

  // MARK: Value alignment tests

  func test1xScaleValueAlignment() {
    XCTAssert(
      CGFloat(1).alignedToPixel(forScreenWithScale: 1) == CGFloat(1),
      "Incorrect screen pixel alignment")
    XCTAssert(
      CGFloat(1.5).alignedToPixel(forScreenWithScale: 1) == CGFloat(2),
      "Incorrect screen pixel alignment")
    XCTAssert(
      CGFloat(500.8232134315).alignedToPixel(forScreenWithScale: 1) == CGFloat(501),
      "Incorrect screen pixel alignment")
  }

  func test2xScaleValueAlignment() {
    XCTAssert(
      CGFloat(1).alignedToPixel(forScreenWithScale: 2) == CGFloat(1),
      "Incorrect screen pixel alignment")
    XCTAssert(
      CGFloat(1.5).alignedToPixel(forScreenWithScale: 2) == CGFloat(1.5),
      "Incorrect screen pixel alignment")
    XCTAssert(
      CGFloat(500.8232134315).alignedToPixel(forScreenWithScale: 2) == CGFloat(501),
      "Incorrect screen pixel alignment")
  }

  func test3xScaleValueAlignment() {
    XCTAssert(
      CGFloat(1).alignedToPixel(forScreenWithScale: 3) == CGFloat(1),
      "Incorrect screen pixel alignment")
    XCTAssert(
      CGFloat(1.5).alignedToPixel(forScreenWithScale: 3) == CGFloat(1.6666666666666667),
      "Incorrect screen pixel alignment")
    XCTAssert(
      CGFloat(500.8232134315).alignedToPixel(forScreenWithScale: 3) == CGFloat(500.6666666666667),
      "Incorrect screen pixel alignment")
  }

  // MARK: Point alignment tests

  func test1xScalePointAlignment() {
    let point1 = CGPoint(x: 1, y: 2.3)
    XCTAssert(
      point1.alignedToPixels(forScreenWithScale: 1) == CGPoint(x: 1, y: 2),
      "Incorrect screen pixel alignment")

    let point2 = CGPoint(x: 100.05, y: -50.51)
    XCTAssert(
      point2.alignedToPixels(forScreenWithScale: 1) == CGPoint(x: 100, y: -51),
      "Incorrect screen pixel alignment")
  }

  func test2xScalePointAlignment() {
    let point1 = CGPoint(x: -0.6, y: 199)
    XCTAssert(
      point1.alignedToPixels(forScreenWithScale: 2) == CGPoint(x: -0.5, y: 199),
      "Incorrect screen pixel alignment")

    let point2 = CGPoint(x: 52.33333333, y: 52.249999)
    XCTAssert(
      point2.alignedToPixels(forScreenWithScale: 2) == CGPoint(x: 52.5, y: 52),
      "Incorrect screen pixel alignment")
  }

  func test3xScalePointAlignment() {
    let point1 = CGPoint(x: -5.6, y: 0.85)
    XCTAssert(
      point1.alignedToPixels(forScreenWithScale: 3) == CGPoint(x: -5.666666666666667, y: 1),
      "Incorrect screen pixel alignment")

    let point2 = CGPoint(x: 99.91, y: 13.25)
    XCTAssert(
      point2.alignedToPixels(forScreenWithScale: 3) == CGPoint(x: 100, y: 13.333333333333334),
      "Incorrect screen pixel alignment")
  }

  // MARK: Rectangle alignment tests

  func test1xScaleRectAlignment() {
    let rect = CGRect(x: 0, y: 1.24, width: 10.25, height: 11.76)
    let expectedRect = CGRect(x: 0, y: 1, width: 10, height: 12)
    XCTAssert(
      rect.alignedToPixels(forScreenWithScale: 1) == expectedRect,
      "Incorrect screen pixel alignment")
  }

  func test2xScaleRectAlignment() {
    let rect = CGRect(x: 5.299999, y: -19.1994, width: 20.25, height: 0.76)
    let expectedRect = CGRect(x: 5.5, y: -19, width: 20.5, height: 1)
    XCTAssert(
      rect.alignedToPixels(forScreenWithScale: 2) == expectedRect,
      "Incorrect screen pixel alignment")
  }

  func test3xScaleRectAlignment() {
    let rect = CGRect(x: 71.13, y: 71.19, width: 20.25, height: 2)
    let expectedRect = CGRect(x: 71, y: 71.33333333333333, width: 20.333333333333332, height: 2)
    XCTAssert(
      rect.alignedToPixels(forScreenWithScale: 3) == expectedRect,
      "Incorrect screen pixel alignment")
  }

  // MARK: CGFloat Approximate Comparison Tests

  func testApproximateEquality() {
    XCTAssert(CGFloat(1.48).isEqual(to: 1.52, screenScale: 2))
    XCTAssert(!CGFloat(1).isEqual(to: 10, screenScale: 9))
    XCTAssert(!CGFloat(1).isEqual(to: 10, screenScale: 9))
    XCTAssert(!CGFloat(1).isEqual(to: 9, screenScale: 9))
    XCTAssert(!CGFloat(1.333).isEqual(to: 1.666, screenScale: 3))
  }

}
