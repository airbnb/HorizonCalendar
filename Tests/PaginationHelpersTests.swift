// Created by Bryan Keller on 1/26/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

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

final class PaginationHelpersTests: XCTestCase {

  func testClosestPageIndex() throws {
    XCTAssert(PaginationHelpers.closestPageIndex(forOffset: 0, pageSize: 100) == 0)
    XCTAssert(PaginationHelpers.closestPageIndex(forOffset: -100, pageSize: 100) == -1)
    XCTAssert(PaginationHelpers.closestPageIndex(forOffset: 100, pageSize: 100) == 1)
    XCTAssert(PaginationHelpers.closestPageIndex(forOffset: -49, pageSize: 100) == 0)
    XCTAssert(PaginationHelpers.closestPageIndex(forOffset: -51, pageSize: 100) == -1)
    XCTAssert(PaginationHelpers.closestPageIndex(forOffset: 49, pageSize: 100) == 0)
    XCTAssert(PaginationHelpers.closestPageIndex(forOffset: 51, pageSize: 100) == 1)
    XCTAssert(PaginationHelpers.closestPageIndex(forOffset: 799, pageSize: 100) == 8)
    XCTAssert(PaginationHelpers.closestPageIndex(forOffset: 801, pageSize: 100) == 8)
    XCTAssert(PaginationHelpers.closestPageIndex(forOffset: -799, pageSize: 100) == -8)
    XCTAssert(PaginationHelpers.closestPageIndex(forOffset: -801, pageSize: 100) == -8)
  }

  // MARK: Closest Page Offset Tests

  func testClosestPageOffsetsNoOffsetNoVelocity() {
    let offset1 = PaginationHelpers.closestPageOffset(
      toTargetOffset: 75,
      touchUpOffset: 75,
      velocity: 0,
      pageSize: 100)
    XCTAssert(offset1 == 100)

    let offset2 = PaginationHelpers.closestPageOffset(
      toTargetOffset: -75,
      touchUpOffset: -75,
      velocity: 0,
      pageSize: 100)
    XCTAssert(offset2 == -100)

    let offset3 = PaginationHelpers.closestPageOffset(
      toTargetOffset: 25,
      touchUpOffset: 25,
      velocity: 0,
      pageSize: 100)
    XCTAssert(offset3 == 0)

    let offset4 = PaginationHelpers.closestPageOffset(
      toTargetOffset: -25,
      touchUpOffset: -25,
      velocity: 0,
      pageSize: 100)
    XCTAssert(offset4 == 0)

    let offset5 = PaginationHelpers.closestPageOffset(
      toTargetOffset: 150,
      touchUpOffset: 150,
      velocity: 0,
      pageSize: 100)
    XCTAssert(offset5 == 200)

    let offset6 = PaginationHelpers.closestPageOffset(
      toTargetOffset: -150,
      touchUpOffset: -150,
      velocity: 0,
      pageSize: 100)
    XCTAssert(offset6 == -200)
  }

  func testClosestPageOffsetsSmallOffsetSmallVelocity() {
    let offset1 = PaginationHelpers.closestPageOffset(
      toTargetOffset: 20,
      touchUpOffset: 10,
      velocity: 1,
      pageSize: 100)
    XCTAssert(offset1 == 100)

    let offset2 = PaginationHelpers.closestPageOffset(
      toTargetOffset: -20,
      touchUpOffset: -10,
      velocity: -1,
      pageSize: 100)
    XCTAssert(offset2 == -100)

    let offset3 = PaginationHelpers.closestPageOffset(
      toTargetOffset: 90,
      touchUpOffset: 80,
      velocity: 1,
      pageSize: 100)
    XCTAssert(offset3 == 100)

    let offset4 = PaginationHelpers.closestPageOffset(
      toTargetOffset: -80,
      touchUpOffset: -80,
      velocity: -1,
      pageSize: 100)
    XCTAssert(offset4 == -100)

    let offset5 = PaginationHelpers.closestPageOffset(
      toTargetOffset: 145,
      touchUpOffset: 135,
      velocity: 1,
      pageSize: 100)
    XCTAssert(offset5 == 200)

    let offset6 = PaginationHelpers.closestPageOffset(
      toTargetOffset: -145,
      touchUpOffset: -135,
      velocity: -1,
      pageSize: 100)
    XCTAssert(offset6 == -200)
  }

  func testClosestPageOffsetsNormalOffsetNormalVelocity() {
    let offset1 = PaginationHelpers.closestPageOffset(
      toTargetOffset: 90,
      touchUpOffset: 40,
      velocity: 5,
      pageSize: 100)
    XCTAssert(offset1 == 100)

    let offset2 = PaginationHelpers.closestPageOffset(
      toTargetOffset: -90,
      touchUpOffset: -50,
      velocity: -5,
      pageSize: 100)
    XCTAssert(offset2 == -100)

    let offset3 = PaginationHelpers.closestPageOffset(
      toTargetOffset: 260,
      touchUpOffset: 110,
      velocity: 10,
      pageSize: 100)
    XCTAssert(offset3 == 300)

    let offset4 = PaginationHelpers.closestPageOffset(
      toTargetOffset: -260,
      touchUpOffset: -110,
      velocity: -10,
      pageSize: 100)
    XCTAssert(offset4 == -300)

    let offset5 = PaginationHelpers.closestPageOffset(
      toTargetOffset: 969,
      touchUpOffset: 420,
      velocity: 13,
      pageSize: 100)
    XCTAssert(offset5 == 1000)

    let offset6 = PaginationHelpers.closestPageOffset(
      toTargetOffset: -969,
      touchUpOffset: -420,
      velocity: -13,
      pageSize: 100)
    XCTAssert(offset6 == -1000)

    let offset7 = PaginationHelpers.closestPageOffset(
      toTargetOffset: -175,
      touchUpOffset: 100,
      velocity: -12,
      pageSize: 100)
    XCTAssert(offset7 == -200)

    let offset8 = PaginationHelpers.closestPageOffset(
      toTargetOffset: 175,
      touchUpOffset: -100,
      velocity: 12,
      pageSize: 100)
    XCTAssert(offset8 == 200)
  }

  // MARK: Adjacent Page Offset Tests

  func testAdjacentPageOffsetsNoOffsetNoVelocity() {
    let offset1 = PaginationHelpers.adjacentPageOffset(
      toPreviousPageIndex: 0,
      targetOffset: 75,
      velocity: 0,
      pageSize: 100)
    XCTAssert(offset1 == 100)

    let offset2 = PaginationHelpers.adjacentPageOffset(
      toPreviousPageIndex: 0,
      targetOffset: -75,
      velocity: 0,
      pageSize: 100)
    XCTAssert(offset2 == -100)

    let offset3 = PaginationHelpers.adjacentPageOffset(
      toPreviousPageIndex: 0,
      targetOffset: 25,
      velocity: 0,
      pageSize: 100)
    XCTAssert(offset3 == 0)

    let offset4 = PaginationHelpers.adjacentPageOffset(
      toPreviousPageIndex: 0,
      targetOffset: -25,
      velocity: 0,
      pageSize: 100)
    XCTAssert(offset4 == 0)

    let offset5 = PaginationHelpers.adjacentPageOffset(
      toPreviousPageIndex: 0,
      targetOffset: 150,
      velocity: 0,
      pageSize: 100)
    XCTAssert(offset5 == 100)

    let offset6 = PaginationHelpers.adjacentPageOffset(
      toPreviousPageIndex: 0,
      targetOffset: -150,
      velocity: 0,
      pageSize: 100)
    XCTAssert(offset6 == -100)

    let offset7 = PaginationHelpers.adjacentPageOffset(
      toPreviousPageIndex: 5,
      targetOffset: 700,
      velocity: 0,
      pageSize: 100)
    XCTAssert(offset7 == 600)

    let offset8 = PaginationHelpers.adjacentPageOffset(
      toPreviousPageIndex: -5,
      targetOffset: -700,
      velocity: 0,
      pageSize: 100)
    XCTAssert(offset8 == -600)
  }

  func testAdjacentPageOffsetsSmallOffsetSmallVelocity() {
    let offset1 = PaginationHelpers.adjacentPageOffset(
      toPreviousPageIndex: 0,
      targetOffset: 20,
      velocity: 1,
      pageSize: 100)
    XCTAssert(offset1 == 100)

    let offset2 = PaginationHelpers.adjacentPageOffset(
      toPreviousPageIndex: 0,
      targetOffset: -20,
      velocity: -1,
      pageSize: 100)
    XCTAssert(offset2 == -100)

    let offset3 = PaginationHelpers.adjacentPageOffset(
      toPreviousPageIndex: 1,
      targetOffset: 110,
      velocity: 1,
      pageSize: 100)
    XCTAssert(offset3 == 200)

    let offset4 = PaginationHelpers.adjacentPageOffset(
      toPreviousPageIndex: -1,
      targetOffset: -110,
      velocity: -1,
      pageSize: 100)
    XCTAssert(offset4 == -200)

    let offset5 = PaginationHelpers.adjacentPageOffset(
      toPreviousPageIndex: 5,
      targetOffset: 501,
      velocity: 1,
      pageSize: 100)
    XCTAssert(offset5 == 600)

    let offset6 = PaginationHelpers.adjacentPageOffset(
      toPreviousPageIndex: -5,
      targetOffset: -501,
      velocity: -1,
      pageSize: 100)
    XCTAssert(offset6 == -600)
  }

  func testAdjacentPageOffsetsLargelOffsetNormalVelocity() {
    let offset1 = PaginationHelpers.adjacentPageOffset(
      toPreviousPageIndex: 0,
      targetOffset: 310,
      velocity: 5,
      pageSize: 100)
    XCTAssert(offset1 == 100)

    let offset2 = PaginationHelpers.adjacentPageOffset(
      toPreviousPageIndex: 0,
      targetOffset: -310,
      velocity: -5,
      pageSize: 100)
    XCTAssert(offset2 == -100)

    let offset3 = PaginationHelpers.adjacentPageOffset(
      toPreviousPageIndex: 10,
      targetOffset: 1600,
      velocity: 10,
      pageSize: 100)
    XCTAssert(offset3 == 1100)

    let offset4 = PaginationHelpers.adjacentPageOffset(
      toPreviousPageIndex: -10,
      targetOffset: -1600,
      velocity: -10,
      pageSize: 100)
    XCTAssert(offset4 == -1100)

    let offset5 = PaginationHelpers.adjacentPageOffset(
      toPreviousPageIndex: -1,
      targetOffset: -10,
      velocity: 5,
      pageSize: 100)
    XCTAssert(offset5 == 0)

    let offset6 = PaginationHelpers.adjacentPageOffset(
      toPreviousPageIndex: 1,
      targetOffset: 10,
      velocity: -5,
      pageSize: 100)
    XCTAssert(offset6 == 0)
  }

}
