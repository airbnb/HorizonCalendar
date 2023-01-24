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
      monthBackgroundItemsEndIndex += 1
      dayRangeItemsEndIndex += 1
      mainItemsEndIndex += 1
      daysOfWeekRowSeparatorItemsEndIndex += 1
      overlayItemsEndIndex += 1
      pinnedDaysOfWeekRowBackgroundEndIndex += 1
      pinnedDayOfWeekItemsEndIndex += 1
      pinnedDaysOfWeekRowSeparatorEndIndex += 1

    case .dayBackground:
      index = dayBackgroundItemsEndIndex
      dayBackgroundItemsEndIndex += 1
      dayRangeItemsEndIndex += 1
      mainItemsEndIndex += 1
      daysOfWeekRowSeparatorItemsEndIndex += 1
      overlayItemsEndIndex += 1
      pinnedDaysOfWeekRowBackgroundEndIndex += 1
      pinnedDayOfWeekItemsEndIndex += 1
      pinnedDaysOfWeekRowSeparatorEndIndex += 1
    
    case .dayRange:
      index = dayRangeItemsEndIndex
      dayRangeItemsEndIndex += 1
      mainItemsEndIndex += 1
      daysOfWeekRowSeparatorItemsEndIndex += 1
      overlayItemsEndIndex += 1
      pinnedDaysOfWeekRowBackgroundEndIndex += 1
      pinnedDayOfWeekItemsEndIndex += 1
      pinnedDaysOfWeekRowSeparatorEndIndex += 1

    case .layoutItemType:
      index = mainItemsEndIndex
      mainItemsEndIndex += 1
      daysOfWeekRowSeparatorItemsEndIndex += 1
      overlayItemsEndIndex += 1
      pinnedDaysOfWeekRowBackgroundEndIndex += 1
      pinnedDayOfWeekItemsEndIndex += 1
      pinnedDaysOfWeekRowSeparatorEndIndex += 1

    case .daysOfWeekRowSeparator:
      index = daysOfWeekRowSeparatorItemsEndIndex
      daysOfWeekRowSeparatorItemsEndIndex += 1
      overlayItemsEndIndex += 1
      pinnedDaysOfWeekRowBackgroundEndIndex += 1
      pinnedDayOfWeekItemsEndIndex += 1
      pinnedDaysOfWeekRowSeparatorEndIndex += 1

    case .overlayItem:
      index = overlayItemsEndIndex
      overlayItemsEndIndex += 1
      pinnedDaysOfWeekRowBackgroundEndIndex += 1
      pinnedDayOfWeekItemsEndIndex += 1
      pinnedDaysOfWeekRowSeparatorEndIndex += 1

    case .pinnedDaysOfWeekRowBackground:
      index = pinnedDaysOfWeekRowBackgroundEndIndex
      pinnedDaysOfWeekRowBackgroundEndIndex += 1
      pinnedDayOfWeekItemsEndIndex += 1
      pinnedDaysOfWeekRowSeparatorEndIndex += 1

    case .pinnedDayOfWeek:
      index = pinnedDayOfWeekItemsEndIndex
      pinnedDayOfWeekItemsEndIndex += 1
      pinnedDaysOfWeekRowSeparatorEndIndex += 1

    case .pinnedDaysOfWeekRowSeparator:
      index = pinnedDaysOfWeekRowSeparatorEndIndex
      pinnedDaysOfWeekRowSeparatorEndIndex += 1
    }

    return index
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

}
