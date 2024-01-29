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

/// Tracks the correct insertion index when adding subviews during layout, ensuring that item views are inserted in the correct position in
/// the `subviews` array so that they're ordered correctly along the z-axis.
final class SubviewInsertionIndexTracker {

  // MARK: Internal

  func insertionIndex(
    forSubviewWithCorrespondingItemType itemType: VisibleItem.ItemType)
    -> Int
  {
    let index: Int
    switch itemType {
    case .monthBackground:
      index = monthBackgroundItemsEndIndex
    case .dayBackground:
      index = dayBackgroundItemsEndIndex
    case .dayRange:
      index = dayRangeItemsEndIndex
    case .layoutItemType:
      index = mainItemsEndIndex
    case .daysOfWeekRowSeparator:
      index = daysOfWeekRowSeparatorItemsEndIndex
    case .overlayItem:
      index = overlayItemsEndIndex
    case .pinnedDaysOfWeekRowBackground:
      index = pinnedDaysOfWeekRowBackgroundEndIndex
    case .pinnedDayOfWeek:
      index = pinnedDayOfWeekItemsEndIndex
    case .pinnedDaysOfWeekRowSeparator:
      index = pinnedDaysOfWeekRowSeparatorEndIndex
    }

    addValue(1, toItemTypesAffectedBy: itemType)

    return index
  }

  func removedSubview(withCorrespondingItemType itemType: VisibleItem.ItemType) {
    addValue(-1, toItemTypesAffectedBy: itemType)
  }

  // MARK: Private

  private var monthBackgroundItemsEndIndex = 0
  private var dayBackgroundItemsEndIndex = 0
  private var dayRangeItemsEndIndex = 0
  private var mainItemsEndIndex = 0
  private var daysOfWeekRowSeparatorItemsEndIndex = 0
  private var overlayItemsEndIndex = 0
  private var pinnedDaysOfWeekRowBackgroundEndIndex = 0
  private var pinnedDayOfWeekItemsEndIndex = 0
  private var pinnedDaysOfWeekRowSeparatorEndIndex = 0

  private func addValue(_ value: Int, toItemTypesAffectedBy itemType: VisibleItem.ItemType) {
    switch itemType {
    case .monthBackground:
      monthBackgroundItemsEndIndex += value
      dayRangeItemsEndIndex += value
      mainItemsEndIndex += value
      daysOfWeekRowSeparatorItemsEndIndex += value
      overlayItemsEndIndex += value
      pinnedDaysOfWeekRowBackgroundEndIndex += value
      pinnedDayOfWeekItemsEndIndex += value
      pinnedDaysOfWeekRowSeparatorEndIndex += value

    case .dayBackground:
      dayBackgroundItemsEndIndex += value
      dayRangeItemsEndIndex += value
      mainItemsEndIndex += value
      daysOfWeekRowSeparatorItemsEndIndex += value
      overlayItemsEndIndex += value
      pinnedDaysOfWeekRowBackgroundEndIndex += value
      pinnedDayOfWeekItemsEndIndex += value
      pinnedDaysOfWeekRowSeparatorEndIndex += value

    case .dayRange:
      dayRangeItemsEndIndex += value
      mainItemsEndIndex += value
      daysOfWeekRowSeparatorItemsEndIndex += value
      overlayItemsEndIndex += value
      pinnedDaysOfWeekRowBackgroundEndIndex += value
      pinnedDayOfWeekItemsEndIndex += value
      pinnedDaysOfWeekRowSeparatorEndIndex += value

    case .layoutItemType:
      mainItemsEndIndex += value
      daysOfWeekRowSeparatorItemsEndIndex += value
      overlayItemsEndIndex += value
      pinnedDaysOfWeekRowBackgroundEndIndex += value
      pinnedDayOfWeekItemsEndIndex += value
      pinnedDaysOfWeekRowSeparatorEndIndex += value

    case .daysOfWeekRowSeparator:
      daysOfWeekRowSeparatorItemsEndIndex += value
      overlayItemsEndIndex += value
      pinnedDaysOfWeekRowBackgroundEndIndex += value
      pinnedDayOfWeekItemsEndIndex += value
      pinnedDaysOfWeekRowSeparatorEndIndex += value

    case .overlayItem:
      overlayItemsEndIndex += value
      pinnedDaysOfWeekRowBackgroundEndIndex += value
      pinnedDayOfWeekItemsEndIndex += value
      pinnedDaysOfWeekRowSeparatorEndIndex += value

    case .pinnedDaysOfWeekRowBackground:
      pinnedDaysOfWeekRowBackgroundEndIndex += value
      pinnedDayOfWeekItemsEndIndex += value
      pinnedDaysOfWeekRowSeparatorEndIndex += value

    case .pinnedDayOfWeek:
      pinnedDayOfWeekItemsEndIndex += value
      pinnedDaysOfWeekRowSeparatorEndIndex += value

    case .pinnedDaysOfWeekRowSeparator:
      pinnedDaysOfWeekRowSeparatorEndIndex += value
    }
  }

}
