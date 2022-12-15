// Created by Bryan Keller on 12/3/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

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

import UIKit

/// Manages adding item views to a parent view, ensuring that the subviews array remains sorted so that subviews have the correct
/// order along the z-axis.
final class SubviewsManager {

  // MARK: Lifecycle

  init(parentView: UIView) {
    self.parentView = parentView
  }

  // MARK: Internal

  // Only used for XCTest support
  var _testSupport_insertedItemTypes = [VisibleItem.ItemType]()

  func insertSubview(_ view: UIView, correspondingItemType: VisibleItem.ItemType) {
    guard let parentView = parentView else { return }

    let index: Int
    switch correspondingItemType {
    case .dayRange:
      index = dayRangeItemsEndIndex
      dayRangeItemsEndIndex += 1
      mainItemsEndIndex += 1
      daysOfWeekRowSeparatorItemsEndIndex += 1
      overlayItemsEndIndex += 1
      pinnedDaysOfWeekRowBackgroundEndIndex += 1
      pinnedDaysOfWeekRowSeparatorEndIndex += 1
      pinnedDayOfWeekItemsEndIndex += 1

    case .layoutItemType:
      index = mainItemsEndIndex
      mainItemsEndIndex += 1
      daysOfWeekRowSeparatorItemsEndIndex += 1
      overlayItemsEndIndex += 1
      pinnedDaysOfWeekRowBackgroundEndIndex += 1
      pinnedDaysOfWeekRowSeparatorEndIndex += 1
      pinnedDayOfWeekItemsEndIndex += 1

    case .daysOfWeekRowSeparator:
      index = daysOfWeekRowSeparatorItemsEndIndex
      daysOfWeekRowSeparatorItemsEndIndex += 1
      overlayItemsEndIndex += 1
      pinnedDaysOfWeekRowBackgroundEndIndex += 1
      pinnedDaysOfWeekRowSeparatorEndIndex += 1
      pinnedDayOfWeekItemsEndIndex += 1

    case .overlayItem:
      index = overlayItemsEndIndex
      overlayItemsEndIndex += 1
      pinnedDaysOfWeekRowBackgroundEndIndex += 1
      pinnedDaysOfWeekRowSeparatorEndIndex += 1
      pinnedDayOfWeekItemsEndIndex += 1

    case .pinnedDaysOfWeekRowBackground:
      index = pinnedDaysOfWeekRowBackgroundEndIndex
      pinnedDaysOfWeekRowBackgroundEndIndex += 1
      pinnedDaysOfWeekRowSeparatorEndIndex += 1
      pinnedDayOfWeekItemsEndIndex += 1

    case .pinnedDaysOfWeekRowSeparator:
      index = pinnedDaysOfWeekRowSeparatorEndIndex
      pinnedDaysOfWeekRowSeparatorEndIndex += 1
      pinnedDayOfWeekItemsEndIndex += 1

    case .pinnedDayOfWeek:
      index = pinnedDayOfWeekItemsEndIndex
      pinnedDayOfWeekItemsEndIndex += 1
    }

    parentView.insertSubview(view, at: index)

    _testSupport_insertedItemTypes.insert(correspondingItemType, at: index)
  }

  // MARK: Private

  private weak var parentView: UIView?

  private var dayRangeItemsEndIndex = 0
  private var mainItemsEndIndex = 0
  private var daysOfWeekRowSeparatorItemsEndIndex = 0
  private var overlayItemsEndIndex = 0
  private var pinnedDaysOfWeekRowBackgroundEndIndex = 0
  private var pinnedDaysOfWeekRowSeparatorEndIndex = 0
  private var pinnedDayOfWeekItemsEndIndex = 0

}
